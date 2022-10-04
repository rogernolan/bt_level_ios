/*
Model for bluetoothe level remote.
 based heavily on http://www.splinter.com.au/2019/06/06/bluetooth-sample-code/
 */

private let restoreIdKey = "OrangeVanBTLEManager"                       // Key for BTCentral to store against
private let peripheralIdDefaultsKey = "LevelProxyPeripheralId"  // User defaults key for us to cache a remote

// These constants are shared with the peripheral data in arduino/bt_constants.h
private let PERIPHERAL_DEVICE_NAME = "Orange Van"
private let LEVEL_SERVICE_UUID = CBUUID(string:"26D23238-4A70-4304-9DC5-09EC6D322F9A")
private let SET_ZERO_SERVICE_UUID = CBUUID(string:"801AF775-722F-4E61-AE2A-06ECBE27381C")

private let HEADING_CHARACTERISTIC_UUID = CBUUID(string:"BEAFB8BF-4088-4EC0-BDEF-F12EE3839580")
private let ROLL_CHARACTERISTIC_UUID = CBUUID(string:"1B65C3F5-9EED-4D42-8574-57ACCC37CBA0")
private let PITCH_CHARACTERISTIC_UUID = CBUUID(string:"0FA9B7F6-5CB7-4654-89B2-102734F0AE4F")


import CoreBluetooth

class LevelProxy: ObservableObject {
    static let shared = LevelProxy()

    let bluetoothCentral = CBCentralManager(delegate: MyCentralManagerDelegate.shared,
                                                                      queue: nil, options: [
                                                                      CBCentralManagerOptionRestoreIdentifierKey: restoreIdKey,
                                                                      ])
    
    @Published var pitch: Float = 0.0
    @Published var roll: Float = 0.0
    @Published var heading: Float = 0.0
    @Published var state = State.idle
    enum State {
        case idle   // not connected
        case searching
        case connected
    }
    
    // internal BTLE state machine
    var btleState = BTLEState.poweredOff {
        // we update the simplified published state when BTLE state changes
        didSet {
            switch btleState {
            case .disconnected, .poweredOff, .outOfRange:
                state = .idle
            case .connected:
                state = .connected
            default:
                state = .searching
            }
        }
    }
    enum BTLEState {
        case poweredOff
        case restoringConnectingPeripheral(CBPeripheral)
        case restoringConnectedPeripheral(CBPeripheral)
        case disconnected
        case scanning
        case connecting(CBPeripheral)
        case discoveringServices(CBPeripheral)
        case discoveringCharacteristics(CBPeripheral)
        case connected(CBPeripheral)
        case outOfRange(CBPeripheral)
        

        var levelSensor: CBPeripheral? {
            switch self {
            case .poweredOff: return nil
            case .restoringConnectingPeripheral(let p): return p
            case .restoringConnectedPeripheral(let p): return p
            case .disconnected: return nil
            case .scanning: return nil
            case .connecting(let p): return p
            case .discoveringServices(let p): return p
            case .discoveringCharacteristics(let p): return p
            case .connected(let p): return p
            case .outOfRange(let p): return p
            }
        }
    }
    
    func start (){
            // not massively sure there is anythign to do here.
    }
    
    func scan() {
        guard bluetoothCentral.state == .poweredOn else {
            print("Cannot scan, BT is not powered on")
            return
        }
        
        // Scan!
        bluetoothCentral.scanForPeripherals(withServices: [LEVEL_SERVICE_UUID] , options: nil)
        btleState = .scanning
    }
    
    func connect(peripheral: CBPeripheral) {
        // Connect!
        // Note: We're retaining the peripheral in the state enum because Apple
        // says: "Pending attempts are cancelled automatically upon
        // deallocation of peripheral"
        bluetoothCentral.connect(peripheral, options: nil)
        btleState = .connecting(peripheral)
    }
    
    // forget: to also purge this peripheral from future attempts to reconnect at startup.
    func disconnect(forget: Bool = false) {
        if let peripheral = btleState.levelSensor {
            bluetoothCentral.cancelPeripheralConnection(peripheral)
        }
        
        if forget {
            UserDefaults.standard.removeObject(forKey: peripheralIdDefaultsKey)
            UserDefaults.standard.synchronize()
        }
        btleState = .disconnected
    }
    
    func setConnected(peripheral: CBPeripheral) {
        guard let pitchCharacteristic = peripheral.pitchCharacteristic,
              let rollCharacteristic = peripheral.rollCharacteristic
            else {
                print("Missing pitch characteristic")
                disconnect()
            return
        }
        
        // Remember the ID for startup reconnecting.
        UserDefaults.standard.set(peripheral.identifier.uuidString, forKey: peripheralIdDefaultsKey)
        UserDefaults.standard.synchronize()

        // Ask for notifications when the peripheral sends us data.
        peripheral.delegate = MyPeripheralDelegate.shared
        peripheral.setNotifyValue(true, for: pitchCharacteristic)
        peripheral.setNotifyValue(true, for: rollCharacteristic)
        
        btleState = .connected(peripheral)
    }
    
    func discoverServices(peripheral: CBPeripheral) {
        peripheral.delegate = MyPeripheralDelegate.shared
        peripheral.discoverServices([LEVEL_SERVICE_UUID])
        btleState = .discoveringServices(peripheral)
    }
    
    func discoverCharacteristics(peripheral: CBPeripheral) {
        guard let myDesiredService = peripheral.levelService else {
            self.disconnect()
            return
        }
        peripheral.delegate = MyPeripheralDelegate.shared
        peripheral.discoverCharacteristics([PITCH_CHARACTERISTIC_UUID, ROLL_CHARACTERISTIC_UUID], for: myDesiredService)
        btleState = .discoveringCharacteristics(peripheral)
    }
    
    func updateMotionData() {
        (roll, pitch) = (0,0)
    }

    func stop() {
     }

    deinit {
        stop()
    }
}

extension LevelProxy {
    func started() -> LevelProxy {
        start()
        return self
    }
}

class MyCentralManagerDelegate: NSObject, CBCentralManagerDelegate {
    static let shared = MyCentralManagerDelegate()
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state  {

        case .poweredOn:        // this is actually the only case we care about
            // Are we transitioning from BT off to BT ready?
            if case .poweredOff = LevelProxy.shared.btleState {
                // check if we have an old connection to restart
                if let peripheralIdStr = UserDefaults.standard.object(forKey: peripheralIdDefaultsKey) as? String,
                    let peripheralId = UUID(uuidString: peripheralIdStr),
                    let previouslyConnected = central
                        .retrievePeripherals(withIdentifiers: [peripheralId])
                        .first {
                            LevelProxy.shared.connect( peripheral: previouslyConnected)
                    
                } else if let systemConnected = central.retrieveConnectedPeripherals(withServices: [LEVEL_SERVICE_UUID]).first {
                    // do we already have a connectoin?

                    LevelProxy.shared.connect(peripheral: systemConnected)

                } else {
                    // Not an error, simply the case that they've never paired
                    // before, or they did a manual unpair:
                    LevelProxy.shared.btleState = .disconnected
                    // so scan for devices
                    LevelProxy.shared.scan()

                }
            }
            
            // Did CoreBluetooth wake us up with a peripheral that was connecting?
            if case .restoringConnectingPeripheral(let peripheral) = LevelProxy.shared.btleState {
                LevelProxy.shared.connect(peripheral: peripheral)
            }
            
            // CoreBluetooth woke us with a 'connected' peripheral, but we had
            // to wait until 'poweredOn' state:
            if case .restoringConnectedPeripheral(let peripheral) = LevelProxy.shared.btleState {
                if peripheral.pitchCharacteristic == nil {
                    LevelProxy.shared.discoverServices(peripheral: peripheral)
                } else {
                    LevelProxy.shared.setConnected(peripheral: peripheral)
                }
            }
            
        default:        // all other core BT states are the same as powered off for us
                LevelProxy.shared.btleState = .poweredOff
        }

    }
    
    // Apple says: This is the first method invoked when your app is relaunched
    // into the background to complete some Bluetooth-related task.
    func centralManager(_ central: CBCentralManager, willRestoreState dict: [String : Any]) {
        let peripherals: [CBPeripheral] = dict[CBCentralManagerRestoredStatePeripheralsKey] as? [CBPeripheral] ?? []
        if peripherals.count > 1 {
            print("Warning: willRestoreState called with >1 connection")
        }
        // We have a peripheral supplied, but we can't touch it until
        // `central.state == .poweredOn`, so we store it in the state
        // machine enum for later use.
        if let peripheral = peripherals.first {
            switch peripheral.state {
            case .connecting: // I've only seen this happen when
                // re-launching attached to Xcode.
                LevelProxy.shared.btleState =
                    .restoringConnectingPeripheral(peripheral)

            case .connected: // Store for connection / requesting
                // notifications when BT starts.
                LevelProxy.shared.btleState =
                    .restoringConnectedPeripheral(peripheral)
            default: break
            }
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,  advertisementData: [String : Any], rssi RSSI: NSNumber) {
        guard case .scanning = LevelProxy.shared.btleState else { return }
        
        central.stopScan()
        LevelProxy.shared.connect(peripheral: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        print("Did connect to \( String(describing: peripheral))")
        if peripheral.pitchCharacteristic == nil {
            LevelProxy.shared.discoverServices(peripheral: peripheral)
        } else {
            LevelProxy.shared.setConnected(peripheral: peripheral)
        }
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        LevelProxy.shared.btleState = .disconnected
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        // Did our currently-connected peripheral just disconnect?
        if LevelProxy.shared.btleState.levelSensor?.identifier == peripheral.identifier {
            // reconnect
            LevelProxy.shared.bluetoothCentral.connect(peripheral)
            LevelProxy.shared.btleState = .outOfRange(peripheral)
        }
    }
}

extension CBPeripheral {
    // Helpers to scan the services list and find the level service
    var levelService: CBService? {
        guard let services = services else { return nil }
        return services.first { $0.uuid == LEVEL_SERVICE_UUID }
    }

// Helpers to scan the characteristic list and find the correspnding characteristic
    var headingCharacteristic: CBCharacteristic? {
        guard let characteristics = levelService?.characteristics else {
            return nil
        }
        return characteristics.first { $0.uuid == HEADING_CHARACTERISTIC_UUID }
    }
    
    var rollCharacteristic: CBCharacteristic? {
        guard let characteristics = levelService?.characteristics else {
            return nil
        }
        return characteristics.first { $0.uuid == ROLL_CHARACTERISTIC_UUID }
    }
    
    var pitchCharacteristic: CBCharacteristic? {
        guard let characteristics = levelService?.characteristics else {
            return nil
        }
        return characteristics.first { $0.uuid == PITCH_CHARACTERISTIC_UUID }
    }
}

extension CBCharacteristic {
    // return data as a Flaot
    var floatValue: Float {
        guard let data = value else {
            return Float.nan
        }
//        let lowbits = data[2]
//        let highbits = data[3]
//        let floatData = Int(lowbits) + Int(highbits)<<8
//
//        let sign = FloatingPointSign(rawValue: (floatData & 0b10000000_00000000) >> 15)!
//        let exponent = (floatData & 0b01111100_00000000) >> 10
//        let significand = (floatData & 0b00000011_11111111)
//
//        return Float(sign: sign, exponent: exponent, significand: significand)
        let value = Float16(bitPattern: UInt16(bigEndian: data.subdata(in: 2..<data.count).withUnsafeBytes { $0.load(as: UInt16.self) }))
        return Float(value)
    }
}

class MyPeripheralDelegate: NSObject, CBPeripheralDelegate {
    static let shared = MyPeripheralDelegate()
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        // Ignore services discovered late.
        guard case .discoveringServices = LevelProxy.shared.btleState else {
            return
        }
        
        if let error = error {
            print("Failed to discover services: \(error)")
            LevelProxy.shared.disconnect()
            return
        }
        guard peripheral.levelService != nil else {
            print("Desired service missing")
            LevelProxy.shared.disconnect()
            return
        }
        
        // Progress to the next step.
        LevelProxy.shared.discoverCharacteristics(peripheral: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        // Ignore characteristics arriving late.
        guard case .discoveringCharacteristics = LevelProxy.shared.btleState
            else
        { return }
        
        if let error = error {
            print("Failed to discover characteristics: \(error)")
            LevelProxy.shared.disconnect()
            return
        }
        guard peripheral.pitchCharacteristic != nil else {
            print("Pitch characteristic missing")
            LevelProxy.shared.disconnect()
            return
        }

        // Ready to go!
        LevelProxy.shared.setConnected(peripheral: peripheral)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            print(error)
            return
        }
        
        let floatValue = characteristic.floatValue
        
        switch characteristic.uuid {
        case HEADING_CHARACTERISTIC_UUID:
            print("Heading to \(floatValue)")
            LevelProxy.shared.heading = floatValue
        case ROLL_CHARACTERISTIC_UUID:
            print("Roll to \(floatValue)")
            LevelProxy.shared.roll = floatValue
        case PITCH_CHARACTERISTIC_UUID:
            print("Pitch to \(floatValue)")

            LevelProxy.shared.pitch = floatValue

        default:
            print("Update for unexpected \(String(describing: characteristic.description)) on \(String(describing: peripheral.name))")

        }

    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        // TODO cancel a setNotifyValue timeout if no error.
        print("notification for \(String(describing: characteristic.description)) on \(String(describing: peripheral.name))")
    }
}

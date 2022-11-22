//
//  FirebaseTempStore.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 22/11/2022.
//

import Foundation
import FirebaseCore
import FirebaseDatabase

class TemperatureStore : ObservableObject {
    @Published var currentTemp: Float = 0.0
    @Published var lastUpdated = Date.now
    
    var ref: DatabaseReference!

    func start () {
        ref = Database.database().reference()

        // single read to initialise.
        ref.child("temp/latest").observe(.value, with: { snapshot in
            // Get latest value
            let latestTempDict = snapshot.value as? NSDictionary
            self.currentTemp = Float(latestTempDict?["temperature"] as? Double ?? 0.0)
                
            let tempSeconds = latestTempDict?["timestamp"] as? Double ?? 0.0
            let interval = TimeInterval(floatLiteral: tempSeconds)
            self.lastUpdated = Date(timeIntervalSince1970: interval)
            
        }) { error in
          print(error.localizedDescription)
        }
    }
    
    func stop() {
        // we don't actually do anything...
    }
}

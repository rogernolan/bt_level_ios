//
//  TempView.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 05/10/2022.
//

import SwiftUI

struct TempView: View {
    
    @EnvironmentObject var firebaseTempStore: TemperatureStore
    
    let formatter = DateFormatter()
    
    init() {
        formatter.dateStyle = .short
        formatter.timeStyle = .short
    }
    
    
    var body: some View {
        VStack {
    
            Text(firebaseTempStore.currentTemp.describeAsFixedLengthString(integerDigits:2, fractionDigits:1))
                .font(.system(size: 100, weight: .light, design: .none))
            let dateString = formatter.string(from: firebaseTempStore.lastUpdated)
            Text(dateString)
                .font(.system(size: 20, weight: .light, design: .none))
        }
        .onAppear {
            firebaseTempStore.start()
        }
        .onDisappear {
            firebaseTempStore.stop()
        }
    }

}

struct TempView_Previews: PreviewProvider {
    
    @StateObject static var firebaseTempStore = TemperatureStore()

    static var previews: some View {
        TempView().environmentObject(firebaseTempStore)
    }
}


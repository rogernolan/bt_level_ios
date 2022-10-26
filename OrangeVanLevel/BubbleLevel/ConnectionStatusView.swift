//
//  ConnectionStatusView.swift
//  OrangeVanLevel
//
//  Created by Roger Nolan on 05/10/2022.
//

import SwiftUI

struct ConnectionDataView: View {
    @EnvironmentObject var level: BTLevelProxy

    var connectionDescription : String {
        switch level.state {
        case .connected:
            return "Connected"
        case .idle:
            return "idle"
        case .searching:
            return "searching"
        }
    }
    
    var connectionIcon : String {
        switch level.state {
        case .connected:
            return "level.fill"
        case .idle:
            return "level"
        case .searching:
            return "level"
        }
    }

    var connectionColour : Color {
        switch level.state {
        case .connected:
            return .green
        case .idle:
            return .yellow
        case .searching:
            return .orange
        }
    }
    
    var body: some View {
        Label (connectionDescription, systemImage:connectionIcon )
            .foregroundColor(connectionColour)
    }
}

struct ConnectionDataView_Previews: PreviewProvider {
    @StateObject static private var motionDetector = BTLevelProxy().started()
    
    static var previews: some View {
        OrientationDataView()
            .environmentObject(motionDetector)
    }
}

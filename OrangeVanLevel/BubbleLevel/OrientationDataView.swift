/*
 Based on Apple's Sample BubbleLevel.
*/

import SwiftUI

struct OrientationDataView: View {
    @EnvironmentObject var detector: BTLevelProxy

    var rollString: String {
        if(detector.rollOrigin < 0.001 ) {
            return detector.roll.describeAsFixedLengthString()
        } else {
            return detector.reportedRoll.describeAsFixedLengthString() + " - " +
                detector.rollOrigin.describeAsFixedLengthString() + " = " +
                detector.roll.describeAsFixedLengthString()
        }
    }

    var pitchString: String {
        if(detector.pitchOrigin < 0.001 ) {
            return detector.pitch.describeAsFixedLengthString()
        } else {
            return detector.reportedPitch.describeAsFixedLengthString() + " - " +
                detector.pitchOrigin.describeAsFixedLengthString() + " = " +
                detector.pitch.describeAsFixedLengthString()
        }

    }

    var body: some View {
        VStack {
            Text("Roll: " + rollString)
                .font(.system(.body, design: .monospaced))
            Text("Pitch: " + pitchString)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct OrientationDataView_Previews: PreviewProvider {
    @StateObject static private var motionDetector = BTLevelProxy().started()
    
    static var previews: some View {
        OrientationDataView()
            .environmentObject(motionDetector)
    }
}

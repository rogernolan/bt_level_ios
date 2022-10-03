/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct OrientationDataView: View {
    @EnvironmentObject var detector: LevelProxy

    var rollString: String {
        detector.roll.describeAsFixedLengthString()
    }

    var pitchString: String {
        detector.pitch.describeAsFixedLengthString()
    }

    var body: some View {
        VStack {
            Text("Horizontal: " + rollString)
                .font(.system(.body, design: .monospaced))
            Text("Vertical: " + pitchString)
                .font(.system(.body, design: .monospaced))
        }
    }
}

struct OrientationDataView_Previews: PreviewProvider {
    @StateObject static private var motionDetector = LevelProxy().started()
    
    static var previews: some View {
        OrientationDataView()
            .environmentObject(motionDetector)
    }
}

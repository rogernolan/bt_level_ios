/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct LevelView: View {
    @EnvironmentObject var level: LevelProxy

    var body: some View {
        VStack {
            BubbleLevel()
            OrientationDataView()
                .padding(.top, 80)
        }
        .onAppear {
            level.start()
        }
        .onDisappear {
            level.stop()
        }
    }
}

struct LevelView_Previews: PreviewProvider {
    @StateObject static var motionDetector = LevelProxy().started()
    
    static var previews: some View {
        LevelView()
            .environmentObject(motionDetector)
    }
}
                                         
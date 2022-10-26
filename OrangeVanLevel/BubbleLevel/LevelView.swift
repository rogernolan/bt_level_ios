/*
 Based on Apple's Sample BubbleLevel.
*/

import SwiftUI

struct LevelView: View {
    @EnvironmentObject var level: BTLevelProxy

    var body: some View {
        VStack {
            BubbleLevel()
            OrientationDataView()
                .padding(.top, 80)
            ConnectionDataView()
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
    @StateObject static var motionDetector = BTLevelProxy().started()
    
    static var previews: some View {
        LevelView()
            .environmentObject(motionDetector)
    }
}
                                         

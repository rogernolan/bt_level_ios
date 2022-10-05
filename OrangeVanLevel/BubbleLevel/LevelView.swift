/*
 Based on Apple's Sample BubbleLevel.
*/

import SwiftUI

struct LevelView: View {
    @EnvironmentObject var level: LevelProxy

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
    @StateObject static var motionDetector = LevelProxy().started()
    
    static var previews: some View {
        LevelView()
            .environmentObject(motionDetector)
    }
}
                                         

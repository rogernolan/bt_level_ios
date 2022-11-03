/*
 Based on Apple's Sample BubbleLevel.
*/

import SwiftUI

struct LevelView: View {
    @EnvironmentObject var level: BTLevelProxy
    @State private var failedToZero = false

    var body: some View {

        VStack {
            ConnectionDataView()
            BubbleLevel()
                .padding(.top, 60)

            OrientationDataView()
                .padding(.top, 60)
            Button("Zero") {
                failedToZero = !level.setZero()
            }
            .padding(.top, 100)
            .alert("Cannot zero more than 5º", isPresented:$failedToZero) {
                // default OK button
            } message: {
                Text("The level must be closer to level to set a zero offset.")
            }
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
                                         

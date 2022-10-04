/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct BubbleLevel: View {
    @EnvironmentObject var btLevel: LevelProxy

    let range : Float = 180
    let maxAngle : Float = 10
    let levelSize: Float = 300

    var bubbleXPosition: CGFloat {
        
        let constrainedRoll = btLevel.roll == 0 ? 0 : min(maxAngle , abs(btLevel.roll)) * (btLevel.roll / abs(btLevel.roll))
        let rollAsFraction = constrainedRoll / maxAngle
        return CGFloat((-rollAsFraction * levelSize/2) + levelSize/2)
    }

    var bubbleYPosition: CGFloat {
        let constrainedPitch = btLevel.pitch == 0 ? 0 : min(maxAngle , abs(btLevel.pitch)) * (btLevel.pitch / abs(btLevel.pitch))
        let pitchAsFraction = constrainedPitch / maxAngle
        return CGFloat((-pitchAsFraction * levelSize/2) + levelSize/2)
    }

    var verticalLine: some View {
        Rectangle()
            .frame(width: 0.5, height: 40)
    }

    var horizontalLine: some View {
        Rectangle()
            .frame(width: 40, height: 0.5)
    }

    var body: some View {
        Circle()
            .foregroundStyle(Color.secondary.opacity(0.25))
            .frame(width: CGFloat(levelSize), height: CGFloat(levelSize))
            .overlay(
                ZStack {
                    
                    Circle()
//                        .withAnimation(.linear(duration: 0.1) {
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                        .position(x: bubbleXPosition, y: bubbleYPosition)
                        .animation(.linear(duration: 0.15), value:bubbleXPosition)
                        .animation(.linear(duration: 0.15), value:bubbleYPosition)

                    Circle()
                        .stroke(lineWidth: 0.5)
                        .frame(width: 20, height: 20)
                    verticalLine
                    horizontalLine
                    
                    verticalLine
                        .position(x: CGFloat(levelSize / 2), y: 0)
                    verticalLine
                        .position(x: CGFloat(levelSize / 2), y: CGFloat(levelSize))
                    horizontalLine
                        .position(x: 0, y: CGFloat(levelSize / 2))
                    horizontalLine
                        .position(x: CGFloat(levelSize), y: CGFloat(levelSize / 2))
                }
            )
    }
}

struct BubbleLevel_Previews: PreviewProvider {
    @StateObject static var motionDetector = LevelProxy().started()

    static var previews: some View {
        BubbleLevel()
            .environmentObject(motionDetector)
    }
}

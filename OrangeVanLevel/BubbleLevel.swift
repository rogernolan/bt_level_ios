/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct BubbleLevel: View {
    @EnvironmentObject var detector: LevelProxy

    let range = Float.pi
    let levelSize: Float = 300

    var bubbleXPosition: CGFloat {
        let zeroBasedRoll = detector.roll + range / 2
        let rollAsFraction = zeroBasedRoll / range
        return CGFloat(rollAsFraction * levelSize)
    }

    var bubbleYPosition: CGFloat {
        let zeroBasedPitch = detector.pitch + range / 2
        let pitchAsFraction = zeroBasedPitch / range
        return CGFloat(pitchAsFraction * levelSize)
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
                        .foregroundColor(.accentColor)
                        .frame(width: 50, height: 50)
                        .position(x: bubbleXPosition,
                                  y: bubbleYPosition)
                    
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

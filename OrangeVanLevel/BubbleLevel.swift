/*
See the License.txt file for this sample’s licensing information.
*/

import SwiftUI

struct BubbleLevel: View {
    @EnvironmentObject var btLevel: LevelProxy

    let maxAngle : Float = 10       // Degrees we measure above this is just "maximum angle"
    let levelSize: CGFloat = 300
    let bubbleSize: CGFloat = 50
    var bubbleMovementLimit: CGFloat  { return  (levelSize - bubbleSize) / 2 }

    // convert the pitch and roll to polar coordiates so we can restrict r to 1
    var polarTheta : CGFloat {
        let constrainedRoll = btLevel.roll == 0 ? 0 : min(maxAngle , abs(btLevel.roll)) * (btLevel.roll / abs(btLevel.roll))
        
        let constrainedPitch = btLevel.pitch == 0 ? 0 : min(maxAngle , abs(btLevel.pitch)) * (btLevel.pitch / abs(btLevel.pitch))
        let theta = CGFloat(atan2(constrainedPitch, constrainedRoll))
        return theta
    }
    
    // polarR is the radius in polar coordinates expressed [0..1] within the maxAngle circle
    var polarR : CGFloat {
        let constrainedRoll = btLevel.roll == 0 ? 0 : min(maxAngle , abs(btLevel.roll)) * (btLevel.roll / abs(btLevel.roll))
        
        let constrainedPitch = btLevel.pitch == 0 ? 0 : min(maxAngle , abs(btLevel.pitch)) * (btLevel.pitch / abs(btLevel.pitch))
        let fullR = sqrt(constrainedRoll*constrainedRoll + constrainedPitch*constrainedPitch)
        let scaledR = fullR/maxAngle
        return CGFloat((min(1.0, scaledR)))
    }
    
    // X position calculated from the polar versions above
    var bubbleXPosition: CGFloat {
        let rawX = polarR * cos(polarTheta)
        return rawX * bubbleMovementLimit + levelSize/2
    }

    var bubbleYPosition: CGFloat {
        let rawY = polarR * sin(polarTheta)
        return rawY * bubbleMovementLimit + levelSize/2
    }

    var verticalLine: some View {
        Rectangle()
            .frame(width: 0.5, height: 40)
    }

    var horizontalLine: some View {
        Rectangle()
            .frame(width: 40, height: 0.5)
    }

    // colour for the bubble based on the distance from 0,0
    var dotColour : Color {
        switch polarR {
        case 0...0.1:
            return .green
        case 0.1...0.5:
            return .yellow
        default:
            return .red
        }
    }
    
    var body: some View {
        Circle()
            .foregroundStyle(Color.secondary.opacity(0.25))
            .frame(width: CGFloat(levelSize), height: CGFloat(levelSize))
            .overlay(
                ZStack {
                    
                    Circle()
                        .foregroundColor(dotColour)
                        .frame(width: bubbleSize, height: bubbleSize)
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

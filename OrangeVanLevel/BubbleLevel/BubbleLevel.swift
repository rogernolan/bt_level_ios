/*
Based on Apple's Sample BubbleLevel.
 */

import SwiftUI

struct BubbleLevel: View {
    @EnvironmentObject var btLevel: BTLevelProxy

    let maxAngle : Float = 10       // Degrees we measure above this is just "maximum angle"

    // convert the pitch and roll to polar coordiates so we can restrict r to 1
    var polarTheta : CGFloat {
        let constrainedRoll = btLevel.roll == 0 ? 0 : min(maxAngle , abs(btLevel.roll)) * (btLevel.roll / abs(btLevel.roll))
        
        let constrainedPitch = btLevel.pitch == 0 ? 0 : min(maxAngle , abs(btLevel.pitch)) * (btLevel.pitch / abs(btLevel.pitch))
        let theta = CGFloat(atan2(constrainedRoll, constrainedPitch))
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
    
    // X and Y position calculated from the polar versions above expressed [0..1] within the size of the level
    var bubbleXScale: CGFloat {
        return polarR * cos(polarTheta)
    }

    var bubbleYScale: CGFloat {
        return polarR * sin(polarTheta)
    }

    var verticalLine: some View {
        Rectangle()
            .frame(width: 0.5, height: 20)
            .foregroundColor(.accentColor)

    }

    var horizontalLine: some View {
        Rectangle()
            .frame(width: 20, height: 0.5)
            .foregroundColor(.accentColor)
    }

    // colour for the bubble based on the distance from 0,0
    var bubbleColour : Color {
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
        
        GeometryReader { geo in
            
            let geometry = geo.frame(in:.local)
            
            let levelSize =  geometry.size.width * 0.8 // 300
            let bubbleSize = geometry.size.width * 0.1 // 20
            
            let rag_gradient = Gradient (colors: [.accentColor, .clear] )
            let grad = RadialGradient(gradient: rag_gradient, center: .center, startRadius: 0.0, endRadius: levelSize/2 )
            
            let bubbleMovementLimit  = (levelSize - bubbleSize) / 2 // keep the bubble inside the circle
            ZStack {
                Circle()
                    .fill(grad)
                    .frame(width: CGFloat(levelSize), height: CGFloat(levelSize), alignment: .center)
                    .overlay{   // OVerlay everything else so we only need to corect the frame of the circle shapeView once.
                        verticalLine.position(x: CGFloat(levelSize / 2), y: 0)
                        verticalLine.position(x: CGFloat(levelSize / 2), y: CGFloat(levelSize))
                        
                        horizontalLine.position(x: 0, y: CGFloat(levelSize / 2))
                        horizontalLine.position(x: CGFloat(levelSize), y: CGFloat(levelSize / 2))
                        
                        Circle().stroke(lineWidth:0.5).foregroundColor(.accentColor)
                        
                        Circle() // the bubble
                            .foregroundColor(bubbleColour)
                            .frame(width: bubbleSize, height: bubbleSize)
                            .position(x: bubbleXScale * bubbleMovementLimit + levelSize/2, y: bubbleYScale * bubbleMovementLimit + levelSize/2)
                            .animation(.linear(duration: 0.15), value:bubbleXScale)
                            .animation(.linear(duration: 0.15), value:bubbleYScale)
                    
                        
                        Circle().stroke(lineWidth: 0.5)
                            .frame(width: bubbleSize * 1.1, height: bubbleSize * 1.1)
                            .foregroundColor(.accentColor)

                        verticalLine
                        horizontalLine
                        
                    }
            }.frame( width: geometry.width, height: geometry.height ) // Because the Geometry Reader doesn't centre its child views.
        }
    }
}

struct BubbleLevel_Previews: PreviewProvider {
    @StateObject static var motionDetector = BTLevelProxy().started()

    static var previews: some View {
        BubbleLevel()
            .environmentObject(motionDetector)
    }
}

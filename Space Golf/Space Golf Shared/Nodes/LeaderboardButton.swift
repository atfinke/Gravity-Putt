//
//  LeaderboardButton.swift
//  Space Golf
//
//  Created by Andrew Finke on 4/10/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class LeaderboardButton: SKNode {
    
    // MARK: - Properties -
    
    var tapped: (() -> Void)?
    
    // MARK: - Initalization -
    
    override init() {
        super.init()
        
        let size: CGFloat = Design.leaderboardButtonSize / 2
        let outerRadius: CGFloat = 5
        let innerRadius: CGFloat = outerRadius / 2
        let spikes = 5
        let spikeAngle = (CGFloat.pi * 2) / CGFloat(spikes)
        let halfSpikeAngle = spikeAngle / 2

        let path = CGMutablePath()
        path.addArc(center: .zero,
                    radius: size,
                    startAngle: 0,
                    endAngle: CGFloat.pi * 2,
                    clockwise: false)
        for spike in 0..<spikes {
            let angle = spikeAngle * CGFloat(spike)

            let leftTriangle = CGPoint(x: cos(angle - halfSpikeAngle) * innerRadius,
                                       y: sin(angle - halfSpikeAngle) * innerRadius)
            let topTriangle = CGPoint(x: cos(angle) * outerRadius,
                                      y: sin(angle) * outerRadius)
            let rightTriangle = CGPoint(x: cos(angle + halfSpikeAngle) * innerRadius,
                                        y: sin(angle + halfSpikeAngle) * innerRadius)

            path.move(to: leftTriangle)
            path.addLine(to: topTriangle)
            path.addLine(to: rightTriangle)
        }
        
        let aaa = CGMutablePath()
        aaa.addRects([
            CGRect(x: -6, y: -6, width: 4, height: 2),
            CGRect(x: -2, y: -6, width: 4, height: 6),
            CGRect(x: 2, y: -6, width: 4, height: 4)
        
        ])
        
        let nodeaaa = SKShapeNode(path: aaa)
                nodeaaa.strokeColor = SKColor.purple.withAlphaComponent(0.5)
//                nodeaaa.lineWidth = 2
        //        node.zRotation = CGFloat.pi / 2
                nodeaaa.fillColor = SKColor.white
               
        
        
        let node = SKShapeNode(path: path)
        node.strokeColor = SKColor.white.withAlphaComponent(1)
        node.lineWidth = 2
//        node.zRotation = CGFloat.pi / 2
        node.fillColor = SKColor.purple.withAlphaComponent(0.5)
        addChild(node)
         addChild(nodeaaa)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

#if os(macOS)
extension LeaderboardButton {
    override func mouseDown(with event: NSEvent) {
        let location = event.location(in: self)
        if frame.contains(location) {
            tapped?()
        }
    }
}
#else
extension LeaderboardButton {
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let location = touches.first?.location(in: self), frame.contains(location) {
            tapped?()
        }
    }
}
#endif

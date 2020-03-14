//
//  Targeting.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Targeting: SKSpriteNode {
    
    let tailLength: CGFloat = 100
    
    let tail: SKShapeNode
    
    init() {
        let radius: CGFloat = 23
        let center = SKShapeNode(circleOfRadius: radius)
        center.fillColor = .clear
        center.strokeColor = .gray
        center.lineWidth = 6
         
        let border = SKShapeNode(circleOfRadius: radius)
        border.fillColor = .yellow
        border.strokeColor = .yellow
        border.lineWidth = 6
        border.position = CGPoint(x: 0, y: 50)
        
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: tailLength))
        let dashed = path.copy(dashingWithPhase: 0, lengths: [12, 12])

        tail = SKShapeNode(path: dashed)
        tail.fillColor = .gray
        tail.strokeColor = .gray
        tail.lineWidth = 6
        tail.position = CGPoint(x: 0, y: -radius * 2)
        tail.zRotation = CGFloat.pi
        
        super.init(texture: nil, color: .clear, size: CGSize(width: 20, height: 20))
        
        
        addChild(center)
        
        
        addChild(border)
        addChild(tail)
        
        
        
        
    }
    
    func updateTail(length: CGFloat) {
//        print(length)
//        tail.yScale = (length - 46) / tailLength
//        print(tail.frame.size)
        
        let path = CGMutablePath()
                      path.move(to: .zero)
                      path.addLine(to: CGPoint(x: 0, y: length))
                      let dashed = path.copy(dashingWithPhase: 0, lengths: [12, 12])

               tail.path = dashed
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

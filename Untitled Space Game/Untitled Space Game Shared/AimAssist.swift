//
//  Targeting.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class AimAssist: SKSpriteNode {
    
    // MARK: - Properties -
    
    let tailLength: CGFloat = 100
    let centerRadius: CGFloat
    let tail: SKShapeNode
    
    // MARK: - Initalization -
    
    init() {
        centerRadius = 8
        
        let center = SKShapeNode(circleOfRadius: centerRadius)
        center.fillColor = .clear
        center.strokeColor = .lightGray
        center.lineWidth = 3
        
        let border = SKShapeNode(circleOfRadius: 3)
        border.fillColor = .white
        border.strokeColor = .white
        border.lineWidth = 3
        border.position = CGPoint(x: 0, y: 20)
        
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 10))
        let dashed = path.copy(dashingWithPhase: 0, lengths: [12, 12])
        
        tail = SKShapeNode(path: dashed)
        tail.fillColor = .lightGray
        tail.strokeColor = .lightGray
        tail.lineWidth = 4
        tail.position = CGPoint(x: 0, y: -centerRadius * 2)
        tail.zRotation = CGFloat.pi
        
        super.init(texture: nil, color: .clear, size: CGSize(width: 20, height: 20))
        zPosition = 10
        
        addChild(center)
        addChild(border)
        addChild(tail)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    
    func updateTail(length: CGFloat) {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: length - centerRadius * 2))
        tail.path = path.copy(dashingWithPhase: 0, lengths: [12, 12])
    }
}

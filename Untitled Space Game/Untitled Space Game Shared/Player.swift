//
//  Player.swift
//  Untitled Space Game iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Player: SKSpriteNode {
    
    // MARK: - Initalization -
    
    init(radius: CGFloat, color: SKColor) {
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.fieldBitMask = SpriteCategory.none
        body.collisionBitMask = SpriteCategory.player
        body.categoryBitMask = SpriteCategory.player
        body.mass = 0.15
        body.linearDamping = 0
        body.friction = 0.95
        physicsBody = body
        
        let border = SKShapeNode(circleOfRadius: radius)
        border.fillColor = color
        border.lineWidth = 2
        border.position = CGPoint(x: 0, y: 0)
        addChild(border)
        
        //        let border = SKShapeNode(circleOfRadius: radius)
        //        border.fillColor = SKColor(white: 0.1, alpha: 1)
        //        border.strokeColor = SKColor(white: 0.2, alpha: 1)
        //        border.lineWidth = 8
        //        border.position = CGPoint(x: 0, y: 50)
        //        addChild(border)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

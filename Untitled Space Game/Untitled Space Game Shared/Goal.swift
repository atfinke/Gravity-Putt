//
//  Goal.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Goal: SKSpriteNode {
    
    // MARK: - Properties -
    
    let border: SKShapeNode
    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = 1
        field.categoryBitMask = SpriteCategory.player
        return field
    }()
    
    // MARK: - Initalization -
    
    init(radius: CGFloat, color: SKColor) {
        let _border = SKShapeNode(circleOfRadius: radius)
        guard let dashed = _border.path?.copy(dashingWithPhase: 0, lengths: [12, 12]) else {
            fatalError()
        }
        
        border = SKShapeNode(path: dashed)
        border.fillColor = .yellow
        border.strokeColor = .yellow
        border.lineWidth = 6
        
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        gravityField.minimumRadius = Float(radius)
        gravityField.region = SKRegion(radius: Float(radius * 4))
        addChild(gravityField)
        addChild(border)
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.contactTestBitMask = SpriteCategory.player
        body.collisionBitMask = SpriteCategory.none
        body.categoryBitMask = SpriteCategory.none
        body.isDynamic = false
        physicsBody = body
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

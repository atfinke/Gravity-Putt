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
        field.strength = 2
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
        border.fillColor = .green
        border.strokeColor = .green
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
        
        let action: SKAction = .repeatForever(.sequence([
            .scale(to: CGFloat.random(in: 0.8..<0.9), duration: 5),
            .wait(forDuration: 0.1),
            .scale(to: 1, duration: 5),
            .wait(forDuration: 0.1)
        ]))
        action.timingMode = .easeInEaseOut
        
        run(action)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    
    func update(color: SKColor) {
        border.fillColor = color
        border.strokeColor = color
    }
}

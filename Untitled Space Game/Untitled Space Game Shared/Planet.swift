//
//  Planet.swift
//  Untitled Space Game iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Planet: SKSpriteNode {
    
    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = Float.random(in: 4...8)
        field.categoryBitMask = SpriteCategory.player
        return field
    }()
    
    init(radius: CGFloat, color: SKColor) {
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        gravityField.region = SKRegion(radius: Float(radius * 3))
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        body.friction = 0.95
        physicsBody = body
        
        let border = SKShapeNode(circleOfRadius: radius)
        border.fillColor = SKColor(white: 0.05, alpha: 1)
        border.strokeColor = .clear//SKColor(white: 0.2, alpha: 1)
        border.lineWidth = 0
        addChild(border)
        
        addChild(gravityField)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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

    init(radius: CGFloat) {
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.affectedByGravity = false
        body.fieldBitMask = SpriteCategory.none
        body.collisionBitMask = SpriteCategory.player
        body.categoryBitMask = SpriteCategory.player
        body.mass = 0.15
        body.linearDamping = 0
        body.angularDamping = 1
        body.friction = 0.95
        physicsBody = body

        let shape = SKShapeNode(circleOfRadius: radius)
        shape.fillColor = .white
        shape.strokeColor = .white
        shape.lineWidth = 2
        shape.position = CGPoint(x: 0, y: 0)
        addChild(shape)

        zPosition = ZPosition.player.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

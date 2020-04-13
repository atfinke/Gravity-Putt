//
//  Player.swift
//  Gravity Golf iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Player: SKNode {

    // MARK: - Initalization -

    init(radius: CGFloat) {
        super.init()

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

        let rendererSize = CGSize(width: 20, height: 30)
        let renderer = ContextRenderer(size: rendererSize)
        let image = renderer.image { ctx in
            SKColor.white.setFill()
            let center = CGPoint(x: rendererSize.width / 2, y: rendererSize.height / 2)
            ctx.cgContext.addArc(center: center,
                                 radius: radius,
                                 startAngle: 0,
                                 endAngle: CGFloat.pi * 2,
                                 clockwise: true)
            ctx.cgContext.fillPath()
        }
        let shape = SKSpriteNode(texture: SKTexture(image: image))
        addChild(shape)

        zPosition = ZPosition.player.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

//
//  Planet.swift
//  Untitled Space Game iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Planet: SKSpriteNode {
    
    // MARK: - Properties -
    
    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = 1.5
        field.categoryBitMask = SpriteCategory.player
        return field
    }()
    
    // MARK: - Initalization -
    
    init(radius: CGFloat, color: SKColor) {
        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))
        
        let gravityFieldRegionRadius = radius * 3
        gravityField.region = SKRegion(radius: Float(gravityFieldRegionRadius))
        addChild(gravityField)
        
        let body = SKPhysicsBody(circleOfRadius: radius)
        body.isDynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        body.friction = 0.95
        body.collisionBitMask = SpriteCategory.player
        body.contactTestBitMask = SpriteCategory.player
        physicsBody = body
        
        let color = SKColor(hue: CGFloat.random(in: 0..<1),
                            saturation: 1,
                            brightness: 0.7,
                            alpha: 1.0)
        
        let gravityFieldTexture = Planet.gravityFieldImage(radius: gravityFieldRegionRadius, color: color)
        let gravityFieldTextureNode = SKSpriteNode(texture: gravityFieldTexture)
        gravityFieldTextureNode.zPosition = ZPosition.stars.rawValue + 1
        addChild(gravityFieldTextureNode)
        
        let fadeAction = SKAction.repeatForever(SKAction.sequence([
            .fadeAlpha(to: CGFloat.random(in: 0.6...1), duration: TimeInterval.random(in: 8...20)),
            .fadeAlpha(to: 1, duration: TimeInterval.random(in: 8...20))
        ]))
        fadeAction.timingMode = .easeInEaseOut
        gravityFieldTextureNode.run(fadeAction)
        
        
        let border = SKShapeNode(circleOfRadius: radius)
        border.zPosition = ZPosition.stars.rawValue + 2
        if PRETTY_COLORS {
            border.fillColor = color//SKColor(white: 0.2, alpha: 1)
            border.strokeColor = SKColor.white.withAlphaComponent(0.8) //SKColor(white: 1, alpha: 1)
        } else {
            border.fillColor = SKColor(white: 0.2, alpha: 1)
            border.strokeColor = SKColor(white: 1, alpha: 1)
        }
        border.lineWidth = 0.075 * radius
        addChild(border)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    static func gravityFieldImage(radius: CGFloat, color: SKColor) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        
        let layer = CAGradientLayer()
        layer.type = .radial
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = [
            color.withAlphaComponent(0.75).cgColor,
            color.withAlphaComponent(0.0).cgColor
        ]
        layer.cornerRadius = radius
        
        let renderer = ContextRenderer(size: size)
        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }
        
        return SKTexture(image: image)
    }
}

//
//  Planet.swift
//  Untitled Space Game iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Planet: SKNode, Codable {

    // MARK: - Properties -

    static let texture = CircleRenderer.standard

    let radius: CGFloat
    let color: SKColor
    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = Design.planetFieldStrength
        field.categoryBitMask = SpriteCategory.player
        return field
    }()

    // MARK: - Initalization -

    init(radius: CGFloat, color: SKColor) {
        self.radius = radius
        self.color = color
        super.init()

        let gravityFieldRegionRadius = radius * 3
        gravityField.region = SKRegion(radius: Float(gravityFieldRegionRadius))

        let gravityFieldTexture = Planet.gravityFieldImage(radius: gravityFieldRegionRadius, color: color)
        let gravityFieldTextureNode = SKSpriteNode(texture: gravityFieldTexture)
        gravityFieldTextureNode.zPosition = ZPosition.planetGravityFieldTexture.rawValue
        addChild(gravityFieldTextureNode)

        let gravityFieldTextureDuration = TimeInterval.random(in: 5...10)
        let gravityFieldTextureAction: SKAction = .repeatForever(.sequence([
            .fadeAlpha(to: CGFloat.random(in: 0.5...0.8), duration: gravityFieldTextureDuration),
            .fadeAlpha(to: 1, duration: gravityFieldTextureDuration)
        ]))
        gravityFieldTextureAction.timingMode = .easeInEaseOut
        gravityFieldTextureNode.run(gravityFieldTextureAction)

        let borderWidth = max(6, 0.09 * radius)
        let borderSprite = SKSpriteNode(texture: Planet.texture,
                                        color: .white,
                                        size: CGSize(width: radius * 2, height: radius * 2))
        borderSprite.colorBlendFactor = 1
        borderSprite.zPosition = ZPosition.planetBorder.rawValue
        addChild(borderSprite)

        let bodyRadius = radius - borderWidth
        let bodySprite = SKSpriteNode(texture: Planet.texture,
                                      size: CGSize(width: bodyRadius * 2, height: bodyRadius * 2))
        bodySprite.colorBlendFactor = 1
        if Design.colors {
            bodySprite.color = color
        } else {
            bodySprite.color = SKColor(white: 0.2, alpha: 1)
        }
        bodySprite.zPosition = ZPosition.planetBody.rawValue
        addChild(bodySprite)

        let physicsBody = SKPhysicsBody(circleOfRadius: radius)
        physicsBody.isDynamic = false
        physicsBody.affectedByGravity = false
        physicsBody.allowsRotation = false
        physicsBody.friction = 0.95
        physicsBody.collisionBitMask = SpriteCategory.player
        physicsBody.contactTestBitMask = SpriteCategory.player

        zPosition = ZPosition.planet.rawValue

        if Debugging.isPlanetInteractionOn {
            self.physicsBody = physicsBody
            addChild(gravityField)
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers -

    static func gravityFieldImage(radius: CGFloat, color: SKColor) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)

        let layer = CAGradientLayer()
        layer.type = .radial
        layer.startPoint = CGPoint(x: 0.5, y: 0.5)
        layer.endPoint = CGPoint(x: 1, y: 1)
        layer.frame = CGRect(origin: .zero, size: size)
        layer.colors = [
            color.withAlphaComponent(0.4).cgColor,
            color.withAlphaComponent(0.0).cgColor
        ]
        layer.cornerRadius = radius

        let renderer = ContextRenderer(size: size)
        let image = renderer.image { context in
            layer.render(in: context.cgContext)
        }

        return SKTexture(image: image)
    }

    // MARK: - Codable -

    enum CodingKeys: String, CodingKey {
        case radius
        case color
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(radius, forKey: .radius)
        try container.encode(SKCodableColor(color), forKey: .color)
    }

    public required convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let radius = try values.decode(CGFloat.self, forKey: .radius)
        let color = try values.decode(SKCodableColor.self, forKey: .color)
        self.init(radius: radius, color: color.color)
    }

}

//
//  Planet.swift
//  Gravity Golf iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Planet: SKNode, Codable {

    // MARK: - Properties -

    static let texture = CircleRenderer.standard
    static let gravityFieldShaderSource: String = {
        guard let path = Bundle.main.path(forResource: "PlanetShader", ofType: "fsh") else {
            fatalError()
        }
        guard let source = try? String(contentsOfFile: path) else {
            fatalError()
        }
        return source
    }()

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

        let borderWidth = max(6, 0.09 * radius)
        let borderSprite = SKSpriteNode(texture: Planet.texture,
                                        color: .white,
                                        size: CGSize(width: radius * 2, height: radius * 2))
        borderSprite.colorBlendFactor = 1
        
        let bodyRadius = radius - borderWidth
        let bodySprite = SKSpriteNode(texture: Planet.texture,
                                      size: CGSize(width: bodyRadius * 2, height: bodyRadius * 2))
        bodySprite.colorBlendFactor = 1
        if Design.colors {
            bodySprite.color = color
        } else {
            bodySprite.color = SKColor(white: 0.2, alpha: 1)
        }
        
        let gravityFieldRegionRadius = radius * 3
        gravityField.region = SKRegion(radius: Float(gravityFieldRegionRadius))
        let gravityFieldShaderNodeSize = CGSize(width: gravityFieldRegionRadius * 2,
                                                height: gravityFieldRegionRadius * 2)
        let gravityFieldShaderNode = SKSpriteNode(texture: nil,
                                                   color: .clear,
                                                   size: gravityFieldShaderNodeSize)
        gravityFieldShaderNode.shader = gravityFieldShader(color: color)
        
        addChild(gravityFieldShaderNode)
        addChild(borderSprite)
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

   func gravityFieldShader(color: SKColor) -> SKShader {
        let ic = color.withAlphaComponent(0.75).rgba()
        let iv = vector_float4([Float(ic.red), Float(ic.green), Float(ic.blue), Float(ic.alpha)])

        let fc = color.withAlphaComponent(0.0).rgba()
        let fv = vector_float4([Float(fc.red), Float(fc.green), Float(fc.blue), Float(fc.alpha)])

        let uniforms: [SKUniform] = [
            SKUniform(name: "u_start_color", vectorFloat4: iv),
            SKUniform(name: "u_end_color", vectorFloat4: fv),
            SKUniform(name: "u_duration", float: Float.random(in: 2...7)),
            SKUniform(name: "u_delay", float: Float.random(in: 0...30)),
            SKUniform(name: "u_min_alpha", float: Float.random(in: 0.5...0.8))
        ]

        return SKShader(source: Planet.gravityFieldShaderSource, uniforms: uniforms)
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

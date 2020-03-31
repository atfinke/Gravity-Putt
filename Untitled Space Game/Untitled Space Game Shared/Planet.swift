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
        gravityField.region = SKRegion(radius: Float(radius * 3))
        addChild(gravityField)

        let path = CGMutablePath()
        let numberOfPoints = 100//Int.random(in: 8..<16)

        var points = [CGPoint]()
        let angle = 2 * CGFloat.pi / CGFloat(numberOfPoints)
        for index in 0..<numberOfPoints {
            let x = radius * sin(CGFloat(index) * angle)
            let y = radius * cos(CGFloat(index) * angle)
            let point = CGPoint(x: x, y: y)
            points.append(point)
            if index == 0 {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        points.append(points[0])

        let body = SKPhysicsBody(polygonFrom: path)
        body.isDynamic = false
        body.affectedByGravity = false
        body.allowsRotation = false
        body.friction = 0.95
        body.collisionBitMask = SpriteCategory.player
        body.contactTestBitMask = SpriteCategory.player
        physicsBody = body

        let color = SKColor(deviceHue: CGFloat.random(in: 0..<1),
                            saturation: 1,
                            brightness: 0.7,
                            alpha: 1.0)

        let _viz = SKShapeNode(circleOfRadius: radius * 3)
        _viz.fillColor = color.withAlphaComponent(0.2)
        _viz.strokeColor = .clear
        //        addChild(_viz)

        let border = SKShapeNode(points: &points, count: points.count)
        if PRETTY_COLORS {
            border.fillColor = color//SKColor(white: 0.2, alpha: 1)
            border.strokeColor = SKColor.white.withAlphaComponent(0.8) //SKColor(white: 1, alpha: 1)
        } else {
            border.fillColor = SKColor(white: 0.2, alpha: 1)
            border.strokeColor = SKColor(white: 1, alpha: 1)
        }
        border.lineWidth = 0.075 * radius
        addChild(border)

        //        let direction = Int.random(in: 0...1) == 1 ? 1 : -1

        //        let action: SKAction = .repeatForever(.sequence([
        //            .rotate(byAngle: CGFloat.pi * CGFloat(direction), duration: TimeInterval.random(in: 15..<45))
        //        ]))

        //        run(action)
        //        addChild(gravityField)

        //        let _viz_planet = SKShapeNode(circleOfRadius: CGFloat(Float(radius * 3)))
        //        _viz_planet.fillColor = color
        //        _viz_planet.zPosition = -10
        //        addChild(_viz_planet)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

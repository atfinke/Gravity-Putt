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

    let borderNode: SKShapeNode
    let innerNode: SKShapeNode

    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = 2
        field.categoryBitMask = SpriteCategory.player
        return field
    }()

    // MARK: - Initalization -

    init(radius: CGFloat, color: SKColor, levelNumber: Int) {
        let outerRadius: CGFloat = radius
        let innerRadius = outerRadius - 10

        let borderPath = CGMutablePath()
        borderPath.move(to: .zero)

        let dashes: CGFloat = 4
        let offset = CGFloat.pi / dashes / 2
        for i in 0..<Int(dashes * 3) {
            let angle = CGFloat.pi / dashes * CGFloat(2 * i) - offset
            let nextAngle = CGFloat.pi / dashes * CGFloat(2 * i + 1) - offset

            let start = CGPoint(x: innerRadius * cos(angle), y: innerRadius * sin(angle))

            borderPath.move(to: start)
            borderPath.addArc(center: .zero,
                              radius: innerRadius,
                              startAngle: angle,
                              endAngle: nextAngle,
                              clockwise: false)

            borderPath.addLine(to: CGPoint(x: outerRadius * cos(nextAngle), y: outerRadius * sin(nextAngle)))
            borderPath.addArc(center: .zero,
                              radius: outerRadius,
                              startAngle: nextAngle,
                              endAngle: angle,
                              clockwise: true)
            borderPath.addLine(to: start)
        }

        borderNode = SKShapeNode(path: borderPath)
//        borderNode.fillColor = .black
        borderNode.strokeColor = SKColor.green.withAlphaComponent(0.5)
        borderNode.lineWidth = 3

        innerNode = SKShapeNode(circleOfRadius: radius / 2)
        innerNode.strokeColor = .white
        innerNode.lineWidth = 3
//        innerNode.fillColor = SKColor(white: 0.1, alpha: 1.0)

        let label = SKLabelNode(text: levelNumber.description)
        label.fontName = "SF Mono Bold"
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.fontSize = 15
        label.fontColor = SKColor.white
        innerNode.addChild(label)

        super.init(texture: nil, color: .clear, size: CGSize(width: radius * 2, height: radius * 2))

        gravityField.minimumRadius = Float(radius)
        gravityField.region = SKRegion(radius: Float(radius * 4))

        addChild(gravityField)
        addChild(borderNode)
        addChild(innerNode)

        let body = SKPhysicsBody(circleOfRadius: radius)
        body.contactTestBitMask = SpriteCategory.player
        body.collisionBitMask = SpriteCategory.none
        body.categoryBitMask = SpriteCategory.none
        body.isDynamic = false
        physicsBody = body
        zPosition = ZPosition.goal.rawValue

        let action: SKAction = .repeatForever(.sequence([
            .rotate(byAngle: -CGFloat.pi, duration: 30)
        ]))
        action.timingMode = .easeInEaseOut

        borderNode.run(action)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

extension SKColor {
    func lerp(color: SKColor, percent: CGFloat) -> SKColor {
        #if os(macOS)
        let ir = redComponent
        let ig = greenComponent
        let ib = blueComponent
        let fr = color.redComponent
        let fg = color.greenComponent
        let fb = color.blueComponent
        #else
        var ir: CGFloat = 0
        var ig: CGFloat = 0
        var ib: CGFloat = 0
        getRed(&ir, green: &ig, blue: &ib, alpha: nil)
        var fr: CGFloat = 0
        var fg: CGFloat = 0
        var fb: CGFloat = 0
        getRed(&fr, green: &fg, blue: &fb, alpha: nil)
        #endif

        return SKColor(red: ir + (fr - ir) * percent,
                       green: ig + (fg - ig) * percent,
                       blue: ib + (fb - ib) * percent,
                       alpha: 1)
    }
}

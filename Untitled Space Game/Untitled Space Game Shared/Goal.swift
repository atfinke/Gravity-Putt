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

    init(radius: CGFloat, levelNumber: Int) {
        let outerBorderPath = CGMutablePath()
        outerBorderPath.move(to: .zero)
        let outerBorderOuterRadius: CGFloat = radius
        let outerBorderInnerRadius = outerBorderOuterRadius - 10
        
        let innerBorderPath = CGMutablePath()
        innerBorderPath.move(to: .zero)
        let innerBorderRadius = radius / 2

        let segments: CGFloat = 4
        let offset = CGFloat.pi / segments / 2
        for i in 0..<Int(segments * 3) {
            let angle = CGFloat.pi / segments * CGFloat(2 * i) - offset
            let nextAngle = CGFloat.pi / segments * CGFloat(2 * i + 1) - offset

            let start = CGPoint(x: outerBorderInnerRadius * cos(angle),
                                y: outerBorderInnerRadius * sin(angle))

            outerBorderPath.move(to: start)
            outerBorderPath.addArc(center: .zero,
                              radius: outerBorderInnerRadius,
                              startAngle: angle,
                              endAngle: nextAngle,
                              clockwise: false)

            outerBorderPath.addLine(to: CGPoint(x: outerBorderOuterRadius * cos(nextAngle), y: outerBorderOuterRadius * sin(nextAngle)))
            outerBorderPath.addArc(center: .zero,
                              radius: outerBorderOuterRadius,
                              startAngle: nextAngle,
                              endAngle: angle,
                              clockwise: true)
            outerBorderPath.addLine(to: start)
            
            let innerStart = CGPoint(x: innerBorderRadius * cos(angle), y: innerBorderRadius * sin(angle))
            innerBorderPath.move(to: innerStart)

            innerBorderPath.addArc(center: .zero,
                              radius: innerBorderRadius,
                              startAngle: angle,
                              endAngle: nextAngle,
                              clockwise: false)
        }

        borderNode = SKShapeNode(path: outerBorderPath)
        borderNode.strokeColor = SKColor.green.withAlphaComponent(0.5)
        borderNode.fillColor = SKColor.black
        borderNode.lineWidth = 3
        
        innerNode = SKShapeNode(path: innerBorderPath)
        innerNode.strokeColor = SKColor.white.withAlphaComponent(0.25)
        innerNode.lineWidth = 3
        
        let label = SKLabelNode(text: levelNumber.description)
        label.fontName = "Menlo Bold"
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
        let ia = alphaComponent
        let fr = color.redComponent
        let fg = color.greenComponent
        let fb = color.blueComponent
        let fa = color.alphaComponent
        #else
        var ir: CGFloat = 0
        var ig: CGFloat = 0
        var ib: CGFloat = 0
        var ia: CGFloat = 0
        getRed(&ir, green: &ig, blue: &ib, alpha: &ia)
        var fr: CGFloat = 0
        var fg: CGFloat = 0
        var fb: CGFloat = 0
        var fa: CGFloat = 0
        getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        #endif

        return SKColor(red: ir + (fr - ir) * percent,
                       green: ig + (fg - ig) * percent,
                       blue: ib + (fb - ib) * percent,
                       alpha: ia + (fa - ia) * percent)
    }
}

//
//  Goal.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Goal: SKNode {

    // MARK: - Properties -

    let borderNode: SKSpriteNode
    let innerNode: SKSpriteNode
    let label: SKLabelNode

    let gravityField: SKFieldNode = {
        let field = SKFieldNode.radialGravityField()
        field.strength = Design.goalFieldStrength
        field.categoryBitMask = SpriteCategory.player
        return field
    }()

    static let textures: (outer: SKTexture, inner: SKTexture) = {
        let outerBorderPath = CGMutablePath()
        outerBorderPath.move(to: .zero)
        let outerBorderOuterRadius: CGFloat = Design.goalRadius
        let outerBorderInnerRadius = outerBorderOuterRadius - 10

        let innerBorderPath = CGMutablePath()
        innerBorderPath.move(to: .zero)
        let innerBorderRadius = Design.goalRadius / 2

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

            outerBorderPath.addLine(to: CGPoint(x: outerBorderOuterRadius * cos(nextAngle),
                                                y: outerBorderOuterRadius * sin(nextAngle)))
            outerBorderPath.addArc(center: .zero,
                                   radius: outerBorderOuterRadius,
                                   startAngle: nextAngle,
                                   endAngle: angle,
                                   clockwise: true)
            outerBorderPath.addLine(to: start)

            let innerStart = CGPoint(x: innerBorderRadius * cos(angle),
                                     y: innerBorderRadius * sin(angle))
            innerBorderPath.move(to: innerStart)

            innerBorderPath.addArc(center: .zero,
                                   radius: innerBorderRadius,
                                   startAngle: angle,
                                   endAngle: nextAngle,
                                   clockwise: false)
        }

        let outerNodeRenderSize = CGSize(width: outerBorderOuterRadius * 2 + 5, height: outerBorderOuterRadius * 2 + 5)
        let outerNodeRenderer = ContextRenderer(size: outerNodeRenderSize)
        let outerNodeImage = outerNodeRenderer.image { ctx in
            SKColor.white.setStroke()
            SKColor.black.setFill()
            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.setLineJoin(.round)
            ctx.cgContext.setLineCap(.round)

            let center = CGPoint(x: outerNodeRenderSize.width / 2, y: outerNodeRenderSize.height / 2)
            var transform = CGAffineTransform(translationX: center.x, y: center.y)
            guard let path = outerBorderPath.copy(using: &transform) else { fatalError() }
            ctx.cgContext.addPath(path)
            ctx.cgContext.strokePath()
        }
        let outerTexture = SKTexture(image: outerNodeImage)

        let innerNodeRenderSize = CGSize(width: innerBorderRadius * 2 + 5, height: innerBorderRadius * 2 + 5)
        let innerNodeRenderer = ContextRenderer(size: innerNodeRenderSize)
        let innerNodeImage = innerNodeRenderer.image { ctx in
            SKColor.white.withAlphaComponent(0.5).setStroke()
            ctx.cgContext.setLineWidth(3)
            ctx.cgContext.setLineJoin(.round)
            ctx.cgContext.setLineCap(.round)

            let center = CGPoint(x: innerNodeRenderSize.width / 2, y: innerNodeRenderSize.height / 2)
            var transform = CGAffineTransform(translationX: center.x, y: center.y)
            guard let path = innerBorderPath.copy(using: &transform) else { fatalError() }
            ctx.cgContext.addPath(path)
            ctx.cgContext.strokePath()
        }
        let innerTexture = SKTexture(image: innerNodeImage)

        return (outerTexture, innerTexture)
    }()

    // MARK: - Initalization -

    init(levelNumber: Int) {
        borderNode = SKSpriteNode(texture: Goal.textures.outer)
        borderNode.colorBlendFactor = 1
        borderNode.color = SKColor.green.withAlphaComponent(0.8)

        innerNode = SKSpriteNode(texture: Goal.textures.inner)

        label = SKLabelNode(text: "")
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center

        let fontSize: CGFloat = 15
        let initalFont = SKFont.systemFont(ofSize: fontSize, weight: .bold)
        guard let descriptor = initalFont.fontDescriptor.withDesign(.monospaced) else {
            fatalError()
        }
        #if os(macOS)
        guard let font = SKFont(descriptor: descriptor, size: fontSize) else {
            fatalError()
        }
        #else
        let font = SKFont(descriptor: descriptor, size: fontSize)
        #endif

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: SKColor.white
        ]
        label.attributedText = NSAttributedString(string: levelNumber.description,
                                                  attributes: attributes)

        super.init()

        gravityField.minimumRadius = Float(Design.goalRadius)
        gravityField.region = SKRegion(radius: Float(Design.goalRadius * 2))

        addChild(gravityField)
        addChild(borderNode)
        addChild(innerNode)
        addChild(label)

        zPosition = ZPosition.goal.rawValue

        let borderRotateAction: SKAction = .repeatForever(.sequence([
            .rotate(byAngle: -CGFloat.pi, duration: 30)
        ]))
        borderRotateAction.timingMode = .easeInEaseOut
        let innerRotateAction: SKAction = .repeatForever(.sequence([
            .rotate(byAngle: CGFloat.pi, duration: 30)
        ]))
        innerRotateAction.timingMode = .easeInEaseOut

        borderNode.run(borderRotateAction)
        innerNode.run(innerRotateAction)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

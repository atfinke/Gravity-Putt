//
//  Targeting.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class AimAssist: SKNode {

    // MARK: - Properties -

    let tipNode: SKSpriteNode
    let center: SKSpriteNode
    let tail: SKShapeNode
    let tailLength: CGFloat = 100

    // MARK: - Initalization -

    override init() {
        let centerRendererSize = CGSize(width: Design.aimAssistInnerRadius * 2 + 5,
                                        height: Design.aimAssistInnerRadius * 2 + 5)
        let centerRenderer = ContextRenderer(size: centerRendererSize)
        let centerImage = centerRenderer.image { ctx in
            SKColor.white.setStroke()
            ctx.cgContext.setLineWidth(4)

            let center = CGPoint(x: centerRendererSize.width / 2,
                                 y: centerRendererSize.height / 2)
            ctx.cgContext.addArc(center: center,
                                 radius: Design.aimAssistInnerRadius,
                                 startAngle: 0,
                                 endAngle: CGFloat.pi * 2,
                                 clockwise: false)
            ctx.cgContext.strokePath()
        }
        center = SKSpriteNode(texture: SKTexture(image: centerImage))

        let tipRendererSize = CGSize(width: 20, height: 30)
        let tipRenderer = ContextRenderer(size: tipRendererSize)
        let tipImage = tipRenderer.image { ctx in
            SKColor.white.setStroke()
            ctx.cgContext.setLineWidth(5)
            ctx.cgContext.setLineJoin(.round)
            ctx.cgContext.setLineCap(.round)

            let center = CGPoint(x: tipRendererSize.width / 2, y: tipRendererSize.height / 2)
            ctx.cgContext.move(to: CGPoint(x: center.x, y: center.y + 10))
            ctx.cgContext.addLine(to: CGPoint(x: center.x + 6, y: center.y))
            ctx.cgContext.addLine(to: CGPoint(x: center.x, y: center.y - 10))
            ctx.cgContext.strokePath()
        }
        tipNode = SKSpriteNode(texture: SKTexture(image: tipImage))
        tipNode.zRotation = CGFloat.pi / 2
        tipNode.position = CGPoint(x: 0, y: 20)

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 10))
        let dashed = path.copy(dashingWithPhase: 0, lengths: [12, 12])

        tail = SKShapeNode(path: dashed)
        tail.lineCap = .round
        tail.lineJoin = .round
        tail.lineWidth = 5
        tail.position = CGPoint(x: 0, y: -Design.aimAssistInnerRadius * 2.5)
        tail.zRotation = CGFloat.pi
        tail.strokeColor = .white

        super.init()
        zPosition = ZPosition.aimAssist.rawValue

        addChild(center)
        addChild(tipNode)
        addChild(tail)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers -

    func update(tailLength: CGFloat) {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: max(0, tailLength - Design.aimAssistInnerRadius * 2)))
        tail.path = path.copy(dashingWithPhase: 0, lengths: [12, 12])
    }

    func update(componentAlphas: CGFloat) {
        tipNode.alpha = componentAlphas
        center.alpha = componentAlphas
        tail.alpha = componentAlphas
    }
}

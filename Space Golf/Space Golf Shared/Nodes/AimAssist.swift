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

    let tipNode: SKShapeNode
    let center = SKShapeNode(circleOfRadius: Design.aimAssistInnerRadius)
    let tail: SKShapeNode
    let tailLength: CGFloat = 100

    // MARK: - Initalization -

    override init() {
        center.fillColor = .clear
        center.lineWidth = 3

        let tipPath = CGMutablePath()
        tipPath.move(to: CGPoint(x: 0, y: 10))
        tipPath.addLine(to: CGPoint(x: 6, y: 0))
        tipPath.addLine(to: CGPoint(x: 0, y: -10))

        tipNode = SKShapeNode(path: tipPath)
        tipNode.fillColor = .clear
        tipNode.lineWidth = 5
        tipNode.zRotation = CGFloat.pi / 2
        tipNode.position = CGPoint(x: 0, y: 20)

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 10))
        let dashed = path.copy(dashingWithPhase: 0, lengths: [12, 12])

        tail = SKShapeNode(path: dashed)
        tail.lineWidth = 5
        tail.position = CGPoint(x: 0, y: -Design.aimAssistInnerRadius * 2.5)
        tail.zRotation = CGFloat.pi

        super.init()
        zPosition = ZPosition.aimAssist.rawValue

        addChild(center)
        addChild(tipNode)
        addChild(tail)

        update(color: SKColor(white: 1, alpha: 1.0))
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

    func update(color: SKColor) {
        tipNode.strokeColor = color
        center.strokeColor = color
        tail.strokeColor = color
    }
}

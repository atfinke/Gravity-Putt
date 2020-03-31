//
//  Targeting.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class AimAssist: SKSpriteNode {

    // MARK: - Properties -

    let tailLength: CGFloat = 100
    let centerRadius: CGFloat
    let tail: SKShapeNode

    // MARK: - Initalization -

    init() {
        centerRadius = 8

        let center = SKShapeNode(circleOfRadius: centerRadius)
        center.fillColor = .clear
        center.strokeColor = .lightGray
        center.lineWidth = 3

        let tip = SKShapeNode(circleOfRadius: 3)
        tip.fillColor = .white
        tip.strokeColor = .white
        tip.lineWidth = 3
        tip.position = CGPoint(x: 0, y: 20)

        let patha = CGMutablePath()
        patha.move(to: CGPoint(x: 0, y: 10))
        patha.addLine(to: CGPoint(x: 6, y: 0))
        patha.addLine(to: CGPoint(x: 0, y: -10))

        let tipNode = SKShapeNode(path: patha)
        tipNode.fillColor = .clear
        tipNode.strokeColor = .white
        tipNode.lineWidth = 4

        tipNode.zRotation = CGFloat.pi / 2
        tipNode.position = CGPoint(x: 0, y: 15)

        //        leftTip.zRotation = CGFloat.pi / 4
        //        leftTip.position = CGPoint(x: -15, y: 20)

        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: 10))
        let dashed = path.copy(dashingWithPhase: 0, lengths: [12, 12])

        tail = SKShapeNode(path: dashed)
        tail.fillColor = .lightGray
        tail.strokeColor = .lightGray
        tail.lineWidth = 4
        tail.position = CGPoint(x: 0, y: -centerRadius * 2)
        tail.zRotation = CGFloat.pi

        super.init(texture: nil, color: .clear, size: CGSize(width: 20, height: 20))
        zPosition = ZPosition.aimAssist.rawValue

        addChild(center)
//        addChild(tip)
        addChild(tipNode)

        addChild(tail)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers -

    func updateTail(length: CGFloat) {
        let path = CGMutablePath()
        path.move(to: .zero)
        path.addLine(to: CGPoint(x: 0, y: max(0, length - centerRadius * 2)))
        tail.path = path.copy(dashingWithPhase: 0, lengths: [12, 12])
    }
}

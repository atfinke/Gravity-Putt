//
//  LeaderboardButton.swift
//  Space Golf
//
//  Created by Andrew Finke on 4/10/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class LeaderboardButton: SKSpriteNode {

    // MARK: - Initalization -

    init() {
        super.init(texture: nil,
                   color: .clear,
                   size: CGSize(width: Design.leaderboardButtonSize,
                                              height: Design.leaderboardButtonSize))

        let circleNode = SKShapeNode(circleOfRadius: Design.leaderboardButtonSize / 2)
        circleNode.strokeColor = SKColor.white.withAlphaComponent(1)
        circleNode.lineWidth = 2
        circleNode.fillColor = SKColor.purple.withAlphaComponent(0.5)
        addChild(circleNode)

        let rectPath = CGMutablePath()
        rectPath.addRects([
            CGRect(x: -6, y: -5, width: 4, height: 7),
            CGRect(x: -2, y: -5, width: 4, height: 11),
            CGRect(x: 2, y: -5, width: 4, height: 9)

        ])

        let rectNode = SKShapeNode(path: rectPath)
        rectNode.strokeColor = SKColor.purple.withAlphaComponent(0.5)
        rectNode.fillColor = SKColor.white
        rectNode.lineCap = .round
        rectNode.lineJoin = .round
        circleNode.addChild(rectNode)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

//
//  LeaderboardButton.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/10/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class LeaderboardButton: SKNode {

    // MARK: - Initalization -

    override init() {
        super.init()
        let rendererSize = CGSize(width: Design.leaderboardButtonSize + 2,
                                  height: Design.leaderboardButtonSize + 2)
        let renderer = ContextRenderer(size: rendererSize)
        let image = renderer.image { ctx in
            SKColor.purple.withAlphaComponent(0.75).setFill()

            let center = CGPoint(x: rendererSize.width / 2, y: rendererSize.height / 2)
            ctx.cgContext.addArc(center: center,
                                 radius: Design.leaderboardButtonSize / 2,
                                 startAngle: 0,
                                 endAngle: CGFloat.pi * 2,
                                 clockwise: true)
            ctx.cgContext.fillPath()

            ctx.cgContext.beginPath()
            SKColor.white.setStroke()
            ctx.cgContext.setLineWidth(2)
            ctx.cgContext.addArc(center: center,
                                 radius: Design.leaderboardButtonSize / 2,
                                 startAngle: 0,
                                 endAngle: CGFloat.pi * 2,
                                 clockwise: true)
            ctx.cgContext.strokePath()

            ctx.cgContext.beginPath()
            SKColor.white.setFill()
            ctx.cgContext.addRects([
                CGRect(x: center.x - 6.5, y: center.y - 1, width: 4, height: 7),
                CGRect(x: center.x - 2, y: center.y - 6, width: 4, height: 12),
                CGRect(x: center.x + 2.5, y: center.y - 3, width: 4, height: 9)
            ])
            ctx.cgContext.fillPath()
        }
        let body = SKSpriteNode(texture: SKTexture(image: image))
        addChild(body)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

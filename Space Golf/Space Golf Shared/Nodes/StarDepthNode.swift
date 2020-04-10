//
//  StarDepthNode.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/23/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class StarDepthNode: SKSpriteNode {

    // MARK: - Properties -

    private static let starTextureCreator = StarTextureCreator()

    // MARK: - Initalization -

    init(size: CGSize, countRange: Range<Int>, radiusRange: Range<CGFloat>) {
        let texture = StarDepthNode.starTextureCreator.create(size: size,
                                                              countRange: countRange,
                                                              radiusRange: radiusRange)
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = ZPosition.stars.rawValue
    }

    init(previousNode: StarDepthNode) {
        guard let texture = previousNode.texture else { fatalError() }
        super.init(texture: texture, color: .clear, size: texture.size())
        zPosition = ZPosition.stars.rawValue
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func showShape() {
        let _viz = SKShapeNode(rectOf: size)
        _viz.fillColor = SKColor.white.withAlphaComponent(0.1)
        _viz.zPosition = -2
        addChild(_viz)
    }
}

//
//  CircleRenderer.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

struct CircleRenderer {

    static let standard = CircleRenderer.create(radius: 50)

    static func create(radius: CGFloat) -> SKTexture {
        let size = CGSize(width: radius * 2, height: radius * 2)
        let context = ContextRenderer(size: size)
        let image = context.image { ctx in
            let context = ctx.cgContext

            let center = CGPoint(x: radius, y: radius)

            context.move(to: center)
            context.addArc(center: center,
                           radius: radius,
                           startAngle: 0,
                           endAngle: CGFloat.pi * 2,
                           clockwise: false)

            SKColor.white.setFill()
            context.fillPath()
        }
        return SKTexture(image: image)
    }
}

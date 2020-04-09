//
//  SKCircleRect.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/8/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreGraphics

struct SKCircleRect: Equatable, Codable {

    // MARK: - Properties -

    let center: CGPoint
    let radius: CGFloat
    var circumference: CGFloat {
        return radius * 2
    }

    var cgRect: CGRect {
        return CGRect(x: center.x - radius,
                      y: center.y - radius,
                      width: radius * 2,
                      height: radius * 2)
    }

    // MARK: - Initalization -

    internal init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }

    internal init(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
        self.center = CGPoint(x: centerX, y: centerY)
        self.radius = radius
    }

    // MARK: - Helpers -

    func intersects(circleRect rect: SKCircleRect) -> Bool {
        let otherRadius = rect.radius
        let otherCenter = rect.center

        let distance = center.distance(to: otherCenter)
        return distance <= (radius + otherRadius)
    }

    func insetBy(d: CGFloat) -> SKCircleRect {
        let r = radius - d  / 2
        return SKCircleRect(center: center, radius: r)
    }

    func offset(by point: CGPoint) -> SKCircleRect {
        let c = CGPoint(x: center.x + point.x, y: center.y + point.y)
        return SKCircleRect(center: c, radius: radius)
    }

}

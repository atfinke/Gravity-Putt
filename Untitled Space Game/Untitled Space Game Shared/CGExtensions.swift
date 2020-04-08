//
//  CGExtensions.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreGraphics

struct SKCircleRect: Equatable, Codable {

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

    internal init(center: CGPoint, radius: CGFloat) {
        self.center = center
        self.radius = radius
    }

    internal init(centerX: CGFloat, centerY: CGFloat, radius: CGFloat) {
        self.center = CGPoint(x: centerX, y: centerY)
        self.radius = radius
    }

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

    func offsetBy(dx: CGFloat, dy: CGFloat) -> SKCircleRect {
        let c = CGPoint(x: center.x + dx, y: center.y + dy)
        return SKCircleRect(center: c, radius: radius)
    }

}

extension CGSize {

    func scaleComponents(by factor: CGFloat) -> CGSize {
        return CGSize(width: width * factor, height: height * factor)
    }

    static func *(lhs: CGSize, factor: Int) -> CGSize {
        return CGSize(width: lhs.width * CGFloat(factor), height: lhs.height * CGFloat(factor))
    }

    static func /(lhs: CGSize, factor: CGFloat) -> CGSize {
        return CGSize(width: lhs.width / CGFloat(factor), height: lhs.height / CGFloat(factor))
    }

}
extension CGPoint {
    func distance(to point: CGPoint) -> CGFloat {
        return sqrt(pow(x - point.x, 2) + pow(y - point.y, 2))
    }

    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }

    static func +(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x, y: lhs.y + rhs.y)
    }

    func scaleComponents(by factor: CGFloat) -> CGPoint {
        return CGPoint(x: x * factor, y: y * factor)
    }

    func vectorized() -> CGVector {
        return CGVector(dx: x, dy: y)
    }

    static func *(lhs: CGPoint, factor: Int) -> CGPoint {
        return CGPoint(x: lhs.x * CGFloat(factor), y: lhs.y * CGFloat(factor))
    }

    static func +(lhs: CGPoint, rhs: CGSize) -> CGPoint {
        return CGPoint(x: lhs.x * rhs.width, y: lhs.y * rhs.height)
    }
}

extension CGVector {
    func magnitude() -> CGFloat {
        return sqrt(pow(dx, 2) + pow(dy, 2))
    }
}

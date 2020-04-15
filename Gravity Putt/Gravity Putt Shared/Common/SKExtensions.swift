//
//  SKExtensions.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

#if os(macOS)
typealias SKFont = NSFont
typealias SKController = NSViewController
extension NSViewController {
    func present(_ controller: NSViewController,
                 animated: Bool,
                 completion:(() -> Void)?) {
        presentAsModalWindow(controller)
    }
}
#else
typealias SKFont = UIFont
typealias SKController = UIViewController
#endif

extension SKColor {
    
    func rgba() -> (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        #if os(macOS)
        let red = redComponent
        let green = greenComponent
        let blue = blueComponent
        let alpha = alphaComponent
        #else
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        #endif
        return (red, green, blue, alpha)
    }
    
    func lerp(color: SKColor, percent: CGFloat) -> SKColor {
        let (ir, ig, ib, ia) = rgba()
        let (fr, fg, fb, fa) = color.rgba()
        return SKColor(red: ir.lerp(value: fr, alpha: percent),
                       green: ig.lerp(value: fg, alpha: percent),
                       blue: ib.lerp(value: fb, alpha: percent),
                       alpha: ia.lerp(value: fa, alpha: percent))
    }
    
    static var randomBackgroundColor: SKColor {
        return SKColor(hue: 280 / 360,
                       saturation: 1,
                       brightness: CGFloat.random(in: 0.08...0.12),
                       alpha: 1.0)
    }
    
    static var randomPlanetColor: SKColor {
        let hues = (0...50).map({ $0 }) + (220...360).map({ $0 })
        let hue = CGFloat(hues.randomElement() ?? 0) / 360
        return SKColor(hue: hue,
                       saturation: 0.9,
                       brightness: CGFloat.random(in: 0.8...1),
                       alpha: 1)
    }
}

extension SKAction {
    static func remove(after duration: TimeInterval) -> SKAction {
        return .sequence([
            .wait(forDuration: duration),
            .removeFromParent()
        ])
    }
}

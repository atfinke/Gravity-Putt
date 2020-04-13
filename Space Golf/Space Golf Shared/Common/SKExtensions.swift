//
//  SKExtensions.swift
//  Untitled Space Game
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

extension SKFont {

    static func score(string: String,
                      size: CGFloat,
                      weight: SKFont.Weight) -> NSAttributedString {
        let initalFont = SKFont.systemFont(ofSize: size, weight: weight)
        guard let descriptor = initalFont.fontDescriptor.withDesign(.monospaced) else {
            fatalError()
        }
        #if os(macOS)
        guard let font = SKFont(descriptor: descriptor, size: size) else {
            fatalError()
        }
        #else
        let font = SKFont(descriptor: descriptor, size: size)
        #endif
        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: SKColor.white
        ]
        return NSAttributedString(string: string, attributes: attributes)
    }
}

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
}

extension SKAction {
    static func remove(after duration: TimeInterval) -> SKAction {
        return .sequence([
            .wait(forDuration: duration),
            .removeFromParent()
        ])
    }
}

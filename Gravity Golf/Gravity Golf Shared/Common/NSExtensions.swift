//
//  NSExtensions.swift
//  Gravity Golf
//
//  Created by Andrew Finke on 4/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import SpriteKit

extension NSAttributedString {
    static func stylized(string: String, size: CGFloat, weight: SKFont.Weight) -> NSAttributedString {
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

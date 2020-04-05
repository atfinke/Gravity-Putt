//
//  SKExtensions.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

extension SKColor {
    func lerp(color: SKColor, percent: CGFloat) -> SKColor {
        #if os(macOS)
        let ir = redComponent
        let ig = greenComponent
        let ib = blueComponent
        let ia = alphaComponent
        let fr = color.redComponent
        let fg = color.greenComponent
        let fb = color.blueComponent
        let fa = color.alphaComponent
        #else
        var ir: CGFloat = 0
        var ig: CGFloat = 0
        var ib: CGFloat = 0
        var ia: CGFloat = 0
        getRed(&ir, green: &ig, blue: &ib, alpha: &ia)
        var fr: CGFloat = 0
        var fg: CGFloat = 0
        var fb: CGFloat = 0
        var fa: CGFloat = 0
        color.getRed(&fr, green: &fg, blue: &fb, alpha: &fa)
        #endif

        return SKColor(red: ir + (fr - ir) * percent,
                       green: ig + (fg - ig) * percent,
                       blue: ib + (fb - ib) * percent,
                       alpha: ia + (fa - ia) * percent)
    }
}

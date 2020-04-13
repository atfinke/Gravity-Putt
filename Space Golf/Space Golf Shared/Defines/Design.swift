//
//  Design.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreGraphics
import Foundation

struct Design {
    static let colors: Bool = true

    static let leaderboardButtonSize: CGFloat = 28

    static let playerRadius: CGFloat = 5

    static let goalRadius: CGFloat = 40.0
    static let goalFieldStrength: Float = 2
    static let goalAsStartScale: CGFloat = 0.5

    static let playerPathNodeRadius: CGFloat = 3
    static let playerPathSpacing: CGFloat = 15

    static let planetFieldStrength: Float = 1.2

    static let aimAssistInnerRadius: CGFloat = 8

    static let levelTransitionDuration: TimeInterval = 2
    static let levelTransitionTimingFunction: ((Float) -> Float) = {
        return { time in
            if time < 0.5 {
                return 2.0 * time * time
            } else {
                return 1.0 - 2.0 * (time - 1.0) * (time - 1.0)
            }
        }
    }()
}

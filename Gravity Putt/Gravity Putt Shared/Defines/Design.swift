//
//  Design.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreGraphics
import Foundation

struct Design {
    // Course generation is independent of the current iPhone window or posture.
    static let iOSCourseSize = CGSize(width: 1000, height: 800)

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

// World coordinates retain their aspect ratio while the viewport fills the view.
// Extra space is visible world, not a change to the course or its physics.
struct GameViewport {
    let sceneSize: CGSize
    let unitsPerPoint: CGFloat

    init?(viewSize: CGSize, courseSize: CGSize) {
        guard viewSize.width.isFinite, viewSize.height.isFinite,
              viewSize.width > 0, viewSize.height > 0,
              courseSize.width > 0, courseSize.height > 0 else { return nil }
        unitsPerPoint = max(courseSize.width / viewSize.width,
                            courseSize.height / viewSize.height)
        sceneSize = CGSize(width: viewSize.width * unitsPerPoint,
                           height: viewSize.height * unitsPerPoint)
    }

    func hudOrigin(safeArea: CGRect) -> CGPoint {
        return CGPoint(x: -sceneSize.width / 2 + (safeArea.minX + 30) * unitsPerPoint,
                       y: sceneSize.height / 2 - (safeArea.maxY - 30) * unitsPerPoint)
    }
}

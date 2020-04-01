//
//  File.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/30/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import CoreGraphics

enum ZPosition: CGFloat {
    case aimAssist = 1_000_000

    case hud = 800_000

    case player = 500_001
    case player_path = 500_000

    case goalInnerBorder = 100_003
    case goalBorder = 100_002
    case goal = 100_001
    case goalParticleSystems = 100_000

    case planet = 1_000

    case stars = 100
}

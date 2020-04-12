//
//  GameStats.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/8/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation

class GameStats: Codable, Equatable {

    // MARK: - Properties -

    var holeStrokes = 0
    private(set) var holeDuration = 0

    var fores = 0
    private(set) var totalPower = 0.0

    var holeStats = [HoleStat]()
    var holeNumber: Int {
        return (holeStats.last?.number ?? 0) + 1
    }
    var completedHolesStrokes: Int {
        return holeStats.map({ $0.strokes }).reduce(0, +)
    }
    var holeInOnes: Int {
        return holeStats.filter({ $0.strokes == 1 }).count
    }

    // MARK: - Initalization -

    init() {
        Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { _ in
            self.holeDuration += 1
        })
    }

    // MARK: - Helpers -

    func completedHole() {
        let stat = HoleStat(number: holeNumber,
                            duration: holeDuration,
                            strokes: holeStrokes)
        holeStats.append(stat)

        holeStrokes = 0
        holeDuration = 0
    }

    // MARK: - Equatable -

    static func == (lhs: GameStats, rhs: GameStats) -> Bool {
        return lhs.holeStrokes == rhs.holeStrokes &&
            lhs.holeDuration == rhs.holeDuration &&
            lhs.fores == rhs.fores &&
            lhs.totalPower == rhs.totalPower &&
            lhs.holeStats == rhs.holeStats
    }
}

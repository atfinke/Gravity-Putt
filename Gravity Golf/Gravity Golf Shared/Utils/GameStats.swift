//
//  GameStats.swift
//  Gravity Golf
//
//  Created by Andrew Finke on 4/8/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import CoreGraphics

#if os(iOS)
import Firebase
#endif

class GameStats: Codable, Equatable {
    
    // MARK: - Types -
    
    private enum Event: String {
        case ace, stroke, fore, completedHole
    }

    // MARK: - Properties -

    private(set) var holeStrokes = 0
    var holeDuration = 0
    private(set) var fores = 0

    var holeStats = [HoleStat]()
    var holeNumber: Int {
        return (holeStats.last?.number ?? 0) + 1
    }
    var completedHolesStrokes: Int {
        return holeStats.map({ $0.strokes }).reduce(0, +)
    }
    var aces: Int {
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
        
        #if os(iOS)
        if holeStrokes == 1 {
            Analytics.logEvent(Event.fore.rawValue, parameters: nil)
        }
        Analytics.logEvent(Event.completedHole.rawValue, parameters: [
            "number": holeNumber,
            "duration": holeDuration,
            "strokes": holeStrokes
        ])
        #endif

        holeStrokes = 0
        holeDuration = 0
    }
    
    func hitShot(power: CGFloat) {
        holeStrokes += 1
        #if os(iOS)
        Analytics.logEvent(Event.stroke.rawValue, parameters: [
            "power": power
        ])
        #endif
    }
    
    func hitFore() {
        fores += 1
        #if os(iOS)
        Analytics.logEvent(Event.fore.rawValue, parameters: nil)
        #endif
    }

    // MARK: - Equatable -

    static func == (lhs: GameStats, rhs: GameStats) -> Bool {
        return lhs.holeStrokes == rhs.holeStrokes &&
            lhs.holeDuration == rhs.holeDuration &&
            lhs.fores == rhs.fores &&
            lhs.holeStats == rhs.holeStats
    }
}


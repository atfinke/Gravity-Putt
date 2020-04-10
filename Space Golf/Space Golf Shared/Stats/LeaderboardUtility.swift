//
//  LeaderboardUtility.swift
//  Space Golf
//
//  Created by Andrew Finke on 4/9/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import GameKit

struct LeaderboardUtility {
    
    #if os(macOS)
    typealias Controller = NSViewController
    #else
    typealias Controller = UIViewController
    #endif
    
    // MARK: - Types -
    
    enum Leaderboard: String {
        case averageStrokesPerHole
        case averageTimePerHole
        case completedHoles
        case fores
        case holeInOnes
    }
    
    // MARK: - Properties -
    
    private let localPlayer = GKLocalPlayer.local
    
    // MARK: - Helpers -
    
    func submit(stats: GameStats) {
        let completedHoles = CGFloat(stats.holeStats.count)
        let totalTime = CGFloat(stats.holeStats.map({ $0.duration }).reduce(0, +))
        
        let averageStrokesPerHole = CGFloat(stats.completedHolesStrokes) / completedHoles
        let averageTimePerHole = totalTime / completedHoles
        
        let scores: [Leaderboard: Any] = [
            .averageStrokesPerHole: averageStrokesPerHole,
            .averageTimePerHole: averageTimePerHole,
            .completedHoles: completedHoles,
            .fores: stats.fores,
            .holeInOnes: stats.holeInOnes
        ]
    }
    
    func authenticate(controller: (Controller) -> (),
                      completion: (_ success: Bool) -> ()) {
        localPlayer.authenticateHandler = { controller, error in
            
        }
    }
}

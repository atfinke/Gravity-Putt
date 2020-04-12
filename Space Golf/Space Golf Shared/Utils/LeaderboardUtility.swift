//
//  LeaderboardUtility.swift
//  Space Golf
//
//  Created by Andrew Finke on 4/9/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import GameKit

class LeaderboardUtility: NSObject, GKGameCenterControllerDelegate {

    // MARK: - Types -

    enum Leaderboard: String {
        case averageStrokesPerHole = "com.andrewfinke.space.golf.leaderboard.asph"
        case averageTimePerHole = "com.andrewfinke.space.golf.leaderboard.atph"
        case completedHoles = "com.andrewfinke.space.golf.leaderboard.completed"
        case fores = "com.andrewfinke.space.golf.leaderboard.fores"
        case holeInOnes = "com.andrewfinke.space.golf.leaderboard.aces"
    }

    // MARK: - Properties -

    private let localPlayer = GKLocalPlayer.local

    // MARK: - Helpers -

    func submit(stats: GameStats) {
        let completedHoles = CGFloat(stats.holeStats.count)
        let totalTime = CGFloat(stats.holeStats.map({ $0.duration }).reduce(0, +))

        let averageStrokesPerHole = CGFloat(stats.completedHolesStrokes) / completedHoles
        let averageTimePerHole = totalTime / completedHoles

        let scores: [Leaderboard: Int64] = [
            .averageStrokesPerHole: Int64(averageStrokesPerHole * 1_000),
            .averageTimePerHole: Int64(averageTimePerHole * 1_000),
            .completedHoles: Int64(completedHoles),
            .fores: Int64(stats.fores),
            .holeInOnes: Int64(stats.holeInOnes)
        ]
        let mapped = scores.map { key, value -> GKScore in
            let score = GKScore(leaderboardIdentifier: key.rawValue)
            score.value = value
            return score
        }
        GKScore.report(mapped, withCompletionHandler: nil)
    }

    func authenticate(authController: @escaping (SKController) -> Void,
                      completion: @escaping (_ success: Bool) -> Void) {
        localPlayer.authenticateHandler = { controller, error in
            DispatchQueue.main.async {
                if let controller = controller {
                    authController(controller)
                } else if let error = error {
                    print(error.localizedDescription)
                    completion(false)
                } else {
                    completion(true)
                }
            }
        }
    }

    func leaderboardController() -> GKGameCenterViewController {
        let controller = GKGameCenterViewController()
        controller.gameCenterDelegate = self
        #if !os(tvOS)
        controller.viewState = .leaderboards
        #endif
        return controller
    }

    // MARK: - GKGameCenterControllerDelegate -

    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        #if os(macOS)
        gameCenterViewController.dismiss(nil)
        #else
        gameCenterViewController.presentingViewController?
            .dismiss(animated: true, completion: nil)
        #endif
        
    }
}

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
        case aces = "com.andrewfinke.space.golf.leaderboard.aces"
        case acesStreak = "com.andrewfinke.space.golf.leaderboard.aces.streak"
    }

    // MARK: - Properties -

    private let localPlayer = GKLocalPlayer.local

    // MARK: - Helpers -

    func submit(stats: GameStats) {
        guard localPlayer.isAuthenticated else {
            return
        }

        let completedHoles = CGFloat(stats.holeStats.count)
        var totalTime: CGFloat = 0
        
        var currentAcesStreak = 0
        var maxAcesStreak = 0
        for hole in stats.holeStats {
            totalTime += CGFloat(hole.duration)
            if hole.strokes == 1 {
                currentAcesStreak += 1
                maxAcesStreak = max(maxAcesStreak, currentAcesStreak)
            } else {
                currentAcesStreak = 0
            }
        }

        let averageStrokesPerHole = CGFloat(stats.completedHolesStrokes) / completedHoles
        let averageTimePerHole = totalTime / completedHoles

        let scores: [Leaderboard: Int64] = [
            .averageStrokesPerHole: Int64(averageStrokesPerHole * 1_000),
            .averageTimePerHole: Int64(averageTimePerHole * 1_000),
            .completedHoles: Int64(completedHoles),
            .fores: Int64(stats.fores),
            .aces: Int64(stats.aces),
            .acesStreak: Int64(maxAcesStreak)
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
        #if DEBUG && os(macOS)
        return
        #endif

        guard !localPlayer.isAuthenticated else {
            completion(true)
            return
        }

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
        controller.title = "Game Center"
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

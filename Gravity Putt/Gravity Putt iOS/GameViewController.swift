//
//  GameViewController.swift
//  Gravity Putt iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    // MARK: - Properties -

    let scene = SaveUtility.loadScene()
    let skView: SKView = {
        let view = SKView()
        view.ignoresSiblingOrder = true

        #if DEBUG
        if !UserDefaults.standard.bool(forKey: "FASTLANE_SNAPSHOT") {
            view.showsFPS = true
            view.showsNodeCount = true
            view.showsDrawCount = true
        }
        #endif

        view.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond
        view.alpha = 0
        return view
    }()

    // MARK: - View Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        scene.presentingController = self
        view.backgroundColor = .black
        view.addSubview(skView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updateViewport()

        guard skView.scene == nil, view.bounds.width > 0, view.bounds.height > 0 else { return }
        skView.presentScene(scene)
        UIView.animate(withDuration: 1.0) {
            self.skView.alpha = 1
        }
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        updateViewport()
    }

    private func updateViewport() {
        skView.frame = view.bounds
        scene.updateViewport(viewSize: view.bounds.size,
                             safeArea: view.bounds.inset(by: view.safeAreaInsets))
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .landscape
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

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

        view.preferredFramesPerSecond = 60
        view.alpha = 0
        return view
    }()

    // MARK: - View Life Cycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        scene.presentingController = self
        view.backgroundColor = .black
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        skView.frame = view.bounds
        view.addSubview(skView)
        skView.presentScene(scene)

        UIView.animate(withDuration: 1.0) {
            self.skView.alpha = 1
        }
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

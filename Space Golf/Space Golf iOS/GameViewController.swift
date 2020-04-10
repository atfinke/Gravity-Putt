//
//  GameViewController.swift
//  Untitled Space Game iOS
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
        view.showsFPS = true
        view.showsNodeCount = true
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

    @objc func doubleTapRecognizer() {
        scene.resetPlayerPosition()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print(view.safeAreaInsets)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}

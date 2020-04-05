//
//  GameViewController.swift
//  Untitled Space Game iOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit

class GameViewController: UIViewController {

    let scene = GameScene.newGameScene()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true
        skView.showsFPS = true
        skView.showsNodeCount = true

        skView.preferredFramesPerSecond = UIScreen.main.maximumFramesPerSecond

        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(doubleTapRecognizer))
        tapGestureRecognizer.numberOfTapsRequired = 1
        tapGestureRecognizer.numberOfTouchesRequired = 2
        view.addGestureRecognizer(tapGestureRecognizer)
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

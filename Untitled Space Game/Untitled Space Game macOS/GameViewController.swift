//
//  GameViewController.swift
//  Untitled Space Game macOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Cocoa
import SpriteKit
import GameplayKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        let scene = GameScene.newGameScene()

        // Present the scene
        let skView = self.view as! SKView
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true

        skView.showsFPS = true
        skView.showsNodeCount = true
//        skView.showsFields = true
        skView.showsQuadCount = true
//        skView.showsPhysics = true
        skView.showsDrawCount = true

        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if $0.keyCode == 124 {
                scene.debugMove(x: 125, y: 0)
            } else if $0.keyCode == 123 {
                scene.debugMove(x: -125, y: 0)
            } else if $0.keyCode == 126 {
                scene.debugMove(x: 0, y: 125)
            } else if $0.keyCode == 125 {
                scene.debugMove(x: 0, y: -125)
            } else {
                return $0
            }
            return nil
        }
    }

}

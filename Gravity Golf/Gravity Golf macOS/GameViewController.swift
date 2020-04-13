//
//  GameViewController.swift
//  Untitled Space Game macOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Cocoa
import SpriteKit

class GameViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        if NSClassFromString("XCTestCase") != nil {
            return
        }

        // Present the scene
        let skView = self.view as! SKView
        let scene = SaveUtility.loadScene()
        scene.presentingController = self
        skView.presentScene(scene)

        skView.ignoresSiblingOrder = true

        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
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
        #endif
    }
}

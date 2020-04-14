//
//  GameViewController.swift
//  Gravity Putt macOS
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Cocoa
import SpriteKit

class GameViewController: NSViewController {
    
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
        return view
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scene.presentingController = self
        
        if NSClassFromString("XCTestCase") != nil {
            return
        }
        
        skView.frame = view.bounds
        view.addSubview(skView)
        skView.presentScene(scene)
        
        #if DEBUG
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            if $0.keyCode == 124 {
                self.scene.debugMove(x: 125, y: 0)
            } else if $0.keyCode == 123 {
                self.scene.debugMove(x: -125, y: 0)
            } else if $0.keyCode == 126 {
                self.scene.debugMove(x: 0, y: 125)
            } else if $0.keyCode == 125 {
                self.scene.debugMove(x: 0, y: -125)
            } else {
                return $0
            }
            return nil
        }
        #endif
    }
    
    override func viewDidLayout() {
        super.viewDidLayout()
        skView.frame = view.bounds
    }
}

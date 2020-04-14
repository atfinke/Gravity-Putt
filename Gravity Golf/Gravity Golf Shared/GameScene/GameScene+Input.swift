//
//  GameScene+Mouse.swift
//  Gravity Golf macOS
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    private func inputDown(sceneLocation: CGPoint, cameraLocation: CGPoint) {
        guard introLabel.parent == nil else { return }
        
        if let unlockNode = unlockNode {
            let buyButton = unlockNode.button.frame.offsetBy(dx: unlockNode.position.x,
                                                             dy: unlockNode.position.y)
            let restoreButton = unlockNode.button.frame.offsetBy(dx: unlockNode.position.x,
                                                                 dy: unlockNode.position.y)
            
            if buyButton.contains(cameraLocation) {
                attemptUnlockPurchase()
                return
            } else if restoreButton.contains(cameraLocation) {
                attemptRestore()
                return
            }
        }
        
        guard unlockNode?.parent == nil else { return }
        
        if leaderboardRect.contains(cameraLocation) {
            showLeaderboard()
            return
        }
        
        #if os(tvOS)
        setTargeting(startLocation: sceneLocation + CGPoint(x: 0, y: -levelSize.height/2 + 100))
        #else
        setTargeting(startLocation: sceneLocation)
        #endif
    }
    
    private func inputMoved(sceneLocation: CGPoint, cameraLocation: CGPoint) {
        guard introLabel.parent == nil && unlockNode?.parent == nil else { return }
        if leaderboardRect.contains(cameraLocation) {
            return
        }
        #if os(tvOS)
        setTargeting(pullBackLocation: sceneLocation + CGPoint(x: 0, y: -levelSize.height/2 + 100))
        #else
        setTargeting(pullBackLocation: sceneLocation)
        #endif
    }
    
    private func inputUp(sceneLocation: CGPoint, cameraLocation: CGPoint) {
        guard introLabel.parent == nil && unlockNode?.parent == nil else { return }
        if leaderboardRect.contains(cameraLocation) {
            return
        }
        #if os(tvOS)
        finishedTargeting(pullBackLocation: sceneLocation + CGPoint(x: 0, y: -levelSize.height/2 + 100))
        #else
        finishedTargeting(pullBackLocation: sceneLocation)
        #endif
    }
    
    private func inputCancelled() {
        aimAssist.run(.fadeOut(withDuration: 0.15))
    }
}

#if os(macOS)

extension GameScene {
    override func mouseDown(with event: NSEvent) {
        inputDown(sceneLocation: event.location(in: self),
                  cameraLocation: event.location(in: cameraNode))
    }
    
    override func mouseDragged(with event: NSEvent) {
        inputMoved(sceneLocation: event.location(in: self),
                   cameraLocation: event.location(in: cameraNode))
    }
    
    override func mouseUp(with event: NSEvent) {
        inputUp(sceneLocation: event.location(in: self),
                cameraLocation: event.location(in: cameraNode))
    }
}

#else

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        inputDown(sceneLocation: touch.location(in: self),
                  cameraLocation: touch.location(in: cameraNode))
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        inputMoved(sceneLocation: touch.location(in: self),
                   cameraLocation: touch.location(in: cameraNode))
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        inputUp(sceneLocation: touch.location(in: self),
                cameraLocation: touch.location(in: cameraNode))
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
        inputCancelled()
    }
}
#endif

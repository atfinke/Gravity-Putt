//
//  GameScene+Mouse.swift
//  Untitled Space Game macOS
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

#if os(macOS)

extension GameScene {

    override func mouseDown(with event: NSEvent) {
        if leaderboardRect.contains(event.location(in: cameraNode)) {
            let controller = leaderboardUtility.leaderboardController()
            presentingController?.present(controller, animated: true, completion: nil)
            return
        }

        setTargeting(startLocation: event.location(in: self))
    }

    override func mouseDragged(with event: NSEvent) {
        if leaderboardRect.contains(event.location(in: cameraNode)) {
            return
        }
        setTargeting(pullBackLocation: event.location(in: self))
    }

    override func mouseUp(with event: NSEvent) {
        if leaderboardRect.contains(event.location(in: cameraNode)) {
            return
        }
        finishedTargeting(pullBackLocation: event.location(in: self))
    }

    override func rightMouseUp(with event: NSEvent) {
        resetPlayerPosition()
    }

}

#else

extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let cameraLocation = touches.first?.location(in: cameraNode),
            leaderboardRect.contains(cameraLocation) {
            let controller = leaderboardUtility.leaderboardController()
            presentingController?.present(controller, animated: true, completion: nil)
            return
        }

        if touches.count == 2 {
            resetPlayerPosition()
            return
        }

        guard let location = touches.first?.location(in: self) else {
            return
        }
        setTargeting(startLocation: location)
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let cameraLocation = touches.first?.location(in: cameraNode),
            leaderboardRect.contains(cameraLocation) {
            return
        }

        guard touches.count == 1, let location = touches.first?.location(in: self) else {
            return
        }
        setTargeting(pullBackLocation: location)
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let cameraLocation = touches.first?.location(in: cameraNode),
            leaderboardRect.contains(cameraLocation) {
            return
        }

        guard touches.count == 1, let location = touches.first?.location(in: self) else {
            return
        }
        finishedTargeting(pullBackLocation: location)
    }

}
#endif

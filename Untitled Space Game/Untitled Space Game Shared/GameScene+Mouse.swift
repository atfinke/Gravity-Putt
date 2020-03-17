//
//  GameScene+Mouse.swift
//  Untitled Space Game macOS
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    override func mouseDown(with event: NSEvent) {
        setTargeting(startLocation: event.location(in: self))
    }
    
    override func mouseDragged(with event: NSEvent) {
        setTargeting(pullBackLocation: event.location(in: self))
    }
    
    override func mouseUp(with event: NSEvent) {
        finishedTargeting(pullBackLocation: event.location(in: self))
    }
    
    override func rightMouseUp(with event: NSEvent) {
        resetPlayerPosition()
    }
    
}

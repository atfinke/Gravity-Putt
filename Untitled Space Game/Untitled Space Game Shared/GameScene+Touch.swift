//
//  GameScene+Touch.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import UIKit

extension GameScene {
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
        guard let location = touches.first?.location(in: self) else {
            return
        }
        setTargeting(pullBackLocation: location)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let location = touches.first?.location(in: self) else {
            return
        }
        finishedTargeting(pullBackLocation: location)
    }
    
    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent?) {
    }

}

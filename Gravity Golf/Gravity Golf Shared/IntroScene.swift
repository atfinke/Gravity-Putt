//
//  IntroScene.swift
//  Untitled Space Game Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class IntroScene: SKScene {
   
    // MARK: - Initalization -
    
    override init(size: CGSize) {
        super.init(size: CGSize(width: 1000, height: 800))
    }
    
    override init() {
        super.init()
        scaleMode = .aspectFill
        backgroundColor = .yellow
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

//
//  PlanetAssetsPrewarm.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 4/14/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import Foundation
import SpriteKit

class PlanetAssetsPrewarm {
    
    static let shared = PlanetAssetsPrewarm()
    
    private let queueCapacity = 10
    private let queue = DispatchQueue(label: "com.andrewfinke.space.golf.planet", qos: .userInteractive)
    private var queued = [(SKColor, SKShader)]()
    
    var isEnabled = false
    
    private init() {
        for _ in 0..<queueCapacity {
            generateAsset()
        }
        Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { _ in
            if !self.isEnabled {
                return
            }
            self.queue.sync {
                if self.queued.count < self.queueCapacity {
                    self.generateAsset()
                }
            }
        }
    }
    
    func generateAsset() {
        let color = SKColor.randomPlanetColor
        let shader = Planet.gravityFieldShader(color: color)
        queued.append((color, shader))
    }
    
    func grabAssets() -> (color: SKColor, shader: SKShader) {
        return queue.sync {
            while queued.isEmpty {
                self.generateAsset()
            }
            return queued.removeFirst()
        }
    }
}

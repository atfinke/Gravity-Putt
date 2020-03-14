//
//  GameScene.swift
//  Untitled Space Game Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {

    let cameraNode = SKCameraNode()
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }
    
    func setUpScene() {
        
        for _ in 0..<50 {
            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.15..<0.75))
            star.fillColor = SKColor(white: CGFloat.random(in: 0.5...1), alpha: 0.8)
            star.position = CGPoint(x: CGFloat.random(in: -size.width / 2...size.width / 2), y: CGFloat.random(in: -size.height / 2...size.height / 2))
            addChild(star)
            
         
        }
        
        backgroundColor = .black
        
        cameraNode.position = CGPoint(x: 0, y: 0)
        addChild(cameraNode)
        camera = cameraNode
        

        let goal = Goal(radius: 0.1 * size.height, color: .yellow)
        goal.position = CGPoint(x: 0.5 * size.width, y: 0.5 * size.height)
        addChild(goal)
        
        let firstPlanet = Planet(radius: 0.3 * size.height, color: .blue)
        firstPlanet.position = CGPoint(x: -0.15 * size.width, y: 0.5 * size.height)
        addChild(firstPlanet)
        
        let secondPlanet = Planet(radius: 0.4 * size.height, color: .red)
        secondPlanet.position = CGPoint(x: 0.5 * size.width, y: -0.5 * size.height)
        addChild(secondPlanet)
        
        player.position = CGPoint(x: -0.4 * size.width, y: 0)
        player.zRotation = -CGFloat.pi / 2
        player.physicsBody?.fieldBitMask = SpriteCategory.none
        addChild(player)

        
       targeting.position = CGPoint(x: -400, y: 0)
        addChild(targeting)
        
        
//        player.run(.applyImpulse(CGVector(dx: 50, dy: 0), duration: 1))
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.isPaused = false
        }
        
//        A circular physics body offers the best performance and can be significantly faster than other physics bodies. If your simulation contains many physics bodies, circular bodies are the best solution
       

    }
    
    let targeting = Targeting()
           
    
    func reset() {
        player.physicsBody?.fieldBitMask = SpriteCategory.none
        player.physicsBody?.velocity = CGVector(dx: 0, dy: 0)
        player.position = CGPoint(x: -0.4 * size.width, y: 0)
        player.physicsBody?.isDynamic = false
        player.physicsBody?.isDynamic = true
    }
    
    override func didMove(to view: SKView) {
        self.setUpScene()
    }
    
    let player = Player(radius: 3, color: .white)
    
    override func update(_ currentTime: TimeInterval) {
        if player.position.y + 100 > size.height / 2 {
            let percent = (player.position.y + 100) / (size.height / 2)
            cameraNode.run( .scale(to: 1 + percent, duration: 1))
        } else if player.position.y - 100 < -size.height / 2 {
            let percent = (player.position.y - 100) / (-size.height / 2)
            cameraNode.run( .scale(to: 1 + percent, duration: 1))
        } else {
            cameraNode.run(.scale(to: 1, duration: 1))
        }
    }
    
    func setTargeting(startLocation: CGPoint) {
        targeting.position = startLocation
    }
    
    func setTargeting(pullBackLocation: CGPoint) {
        let rawMagnitude = sqrt(pow(pullBackLocation.x - targeting.position.x, 2) + pow(pullBackLocation.x - targeting.position.x, 2))
        
        let angle = -atan2(pullBackLocation.x - targeting.position.x,
                           pullBackLocation.y - targeting.position.y)
        targeting.zRotation = angle + CGFloat.pi
        targeting.updateTail(length: rawMagnitude)
    }
    
    func finishedTargeting(pullBackLocation: CGPoint) {
        let rawMagnitude = sqrt(pow(pullBackLocation.x - targeting.position.x, 2) + pow(pullBackLocation.x - targeting.position.x, 2))
        let mag: CGFloat = rawMagnitude / 5
        let x = mag * -sin(targeting.zRotation)
        let y = mag * cos(targeting.zRotation)
        player.physicsBody?.fieldBitMask = SpriteCategory.player
        player.run(.applyImpulse(CGVector(dx: x, dy: y), duration: 0.5))
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
            self.reset()
        }
    }
}

#if os(iOS) || os(tvOS)
// Touch-based event handling
extension GameScene {

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
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
#endif

#if os(OSX)
// Mouse-based event handling
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

}
#endif


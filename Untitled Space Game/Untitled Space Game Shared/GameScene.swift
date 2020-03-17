//
//  GameScene.swift
//  Untitled Space Game Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class GameScene: SKScene {
    
    // MARK: - Properties -
    
    let aimAssist = AimAssist()
    let cameraNode = SKCameraNode()
    
    let player: Player = {
        let player = Player(radius: 5, color: .white)
        player.zRotation = -CGFloat.pi / 2
        return player
    }()
    
    var lastLevel: Level?
    var levels = [Level]()
    var goalRectsWorldSpace = [CGRect]()
    
    var playerNeedsPhysicsBodyDynamics = false
    
    // MARK: - Initalization -
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        setUpScene()
    }
    
    func setUpScene() {
        backgroundColor = SKColor(white: 0.05, alpha: 1)

        addChild(cameraNode)
        camera = cameraNode
        
        player.position = CGPoint(x: -size.width / 2, y: 0)
        addChild(player)
        
        let startSize = CGSize(width: 200, height: 200)
        let initalLevel = Level(size: size, startSize: startSize)
        initalLevel.position = CGPoint(x: -startSize.height / 2,
                                       y: -initalLevel.startRect.origin.y - startSize.height / 2)
        
        let goalRectWorldSpaceX = initalLevel.position.x - initalLevel.goalSafeRect.width / 2
        let goalRectWorldSpaceY = initalLevel.position.y - initalLevel.goalSafeRect.height / 2
        let goalRectWorldSpace = initalLevel.goalSafeRect.offsetBy(dx: goalRectWorldSpaceX,
                                                                   dy: goalRectWorldSpaceY)
        goalRectsWorldSpace.append(goalRectWorldSpace)
        
        levels.append(initalLevel)
        addChild(initalLevel)
        
        for _ in 0..<2 {
            addLevel()
        }
        moveToLevel(at: 0)
        
        aimAssist.alpha = 0.0
        addChild(aimAssist)
        
        physicsWorld.contactDelegate = self
    }
    
    // MARK: - Level Management -
    
    func addLevel() {
        guard let finalLevel = levels.last else {
            fatalError()
        }
        
        let level = Level(size: size, startSize: finalLevel.goalSafeRect.size)
        level.name = (levels.count + 2).description
        let positionX = finalLevel.position.x
            + finalLevel.goalSafeRect.origin.x
            - level.startRect.width / 2
            - level.startRect.minX
        let positionY = finalLevel.position.y
            + finalLevel.goalSafeRect.origin.y
            - level.startRect.height / 2
            - level.startRect.minY
        
        level.position = CGPoint(x: positionX, y: positionY)
        
        let goalSafeOffsetX = level.position.x - level.goalSafeRect.width / 2
        let goalSafeOffsetY = level.position.y - level.goalSafeRect.height / 2
        let goalSafeWorldRect = level.goalSafeRect.offsetBy(dx: goalSafeOffsetX, dy: goalSafeOffsetY)

        levels.append(level)
        goalRectsWorldSpace.append(goalSafeWorldRect)
        addChild(level)
    }
    
    func moveToLevel(at index: Int) {
        lastLevel?.removeFromParent()
        if index > 0 {
            lastLevel = levels[index - 1]
        }
        
        let level = levels[index]
        let position = CGPoint(x: level.position.x + level.frame.size.width / 2,
                               y: level.position.y + level.frame.size.height / 2)
        
        goalRectsWorldSpace.removeFirst(index)
        let levelsToRemove = levels.prefix(index)
        levels.removeFirst(index)
        for (levelToRemoveIndex, levelToRemove) in levelsToRemove.enumerated() {
            if levelToRemoveIndex == levelsToRemove.count - 1 {
                levelToRemove.goalNode.gravityField.removeFromParent()
                let color = SKColor.blue
                levelToRemove.goalNode.border.run(.colorize(with: color, colorBlendFactor: 1.0, duration: 1))
            } else {
                levelToRemove.removeFromParent()
            }
        }
        
        let color = SKColor(white: CGFloat.random(in: 0..<0.1), alpha: 1)
        run(.colorize(with: color, colorBlendFactor: 1.0, duration: 1))
        cameraNode.run(.move(to: position, duration: 1))
        for _ in 0..<index {
            addLevel()
        }
        resetPlayerPosition()
    }
    
    // MARK: - Aiming -
    
    func setTargeting(startLocation: CGPoint) {
        aimAssist.position = startLocation
        aimAssist.run(.fadeIn(withDuration: 0.15))
    }
    
    func setTargeting(pullBackLocation: CGPoint) {
        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let angle = -atan2(pullBackLocation.x - aimAssist.position.x,
                           pullBackLocation.y - aimAssist.position.y)
        aimAssist.zRotation = angle + CGFloat.pi
        aimAssist.updateTail(length: magnitude)
    }
    
    func finishedTargeting(pullBackLocation: CGPoint) {
        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let mag: CGFloat = magnitude / 5
        let x = mag * -sin(aimAssist.zRotation)
        let y = mag * cos(aimAssist.zRotation)
        player.physicsBody?.fieldBitMask = SpriteCategory.player
        player.run(.applyImpulse(CGVector(dx: x, dy: y), duration: 0.5))
        aimAssist.run(.fadeOut(withDuration: 0.15))
    }
    
    // MARK: - Player -
    
    func resetPlayerPosition() {
        guard let physicsBody = player.physicsBody, let level = levels.first else {
            fatalError()
        }
        
        physicsBody.fieldBitMask = SpriteCategory.none
        physicsBody.velocity = CGVector(dx: 0, dy: 0)
        physicsBody.isDynamic = false
        
        let startRectWorldSpace = level.startRect.offsetBy(dx: level.position.x,
                                                         dy: level.position.y)
        player.position = CGPoint(x: startRectWorldSpace.minX + startRectWorldSpace.width / 2,
                                  y: startRectWorldSpace.minY + startRectWorldSpace.height / 2)
  
        playerNeedsPhysicsBodyDynamics = true
    }
    
    // MARK: - SKScene Overrides -
    
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        
        if let level = levels.first {
            let safeWidthPadding: CGFloat = size.width / 10
            let levelMinXWorldSpace = level.position.x - size.width / 2 + safeWidthPadding
            let levelMaxXWorldSpace = level.position.x + size.width / 2 - safeWidthPadding
            
            let safeHeightPadding: CGFloat = size.height / 10
            let levelMinYWorldSpace = level.position.y - size.height / 2 + safeHeightPadding
            let levelMaxYWorldSpace = level.position.y + size.height / 2 - safeHeightPadding
            
            var scale: CGFloat = 1.0
            if player.position.x > levelMaxXWorldSpace  {
                scale = max(scale, 1.0 + (player.position.x - levelMaxXWorldSpace) / (size.width / 2))
            } else if player.position.x < levelMinXWorldSpace {
                scale = max(scale, 1.0 + (levelMinXWorldSpace - player.position.x) / (size.width / 2))
            }
            
            if player.position.y > levelMaxYWorldSpace  {
                scale = max(scale, 1.0 + (player.position.y - levelMaxYWorldSpace) / (size.height / 2))
            } else if player.position.y < levelMinYWorldSpace {
                scale = max(scale, 1.0 + (levelMinYWorldSpace - player.position.y) / (size.height / 2))
            }
            
            cameraNode.run(.scale(to: min(scale, 2), duration: 0.25))
            
            if scale > 2.5 {
                resetPlayerPosition()
            } else {
                
            }
        }
        
        if let physicsBody = player.physicsBody {
            let velocity = physicsBody.velocity
            let magnitude = velocity.magnitude()
            for (index, goalRect) in goalRectsWorldSpace.enumerated() {
                let goalCenter = CGPoint(x: goalRect.midX, y: goalRect.midY)
                let dist = goalCenter.distance(to: player.position)
                if dist < 40 {
                    if dist > 10 {
                        physicsBody.velocity = CGVector(dx: velocity.dx * 0.9,
                                                        dy: velocity.dy * 0.9)
                    }
                    if magnitude < 10 && dist < 10 {
                        moveToLevel(at: index + 1)
                    } else if magnitude < 20 {
                        levels[index].goalNode.gravityField.strength = 1
                    }
                    break
                }
//                 else if dist < 40 {
//                    let velocityX = velocity.dx
//                    let velocityY = velocity.dy
//
//                    break
//                }
            }
        }
    }
    
    override func didSimulatePhysics() {
        super.didSimulatePhysics()
        if playerNeedsPhysicsBodyDynamics {
            playerNeedsPhysicsBodyDynamics = false
            player.physicsBody?.isDynamic = true
            player.physicsBody?.linearDamping = 0.0
        }
    }
    
}

extension GameScene: SKPhysicsContactDelegate {
    
    // MARK: - SKPhysicsContactDelegate -
    
    func didBegin(_ contact: SKPhysicsContact) {
        if let player = contact.bodyA.node as? Player,
            let playerBody = player.physicsBody,
            let goal = contact.bodyB.node as? Goal,
            goal != lastLevel?.goalNode {
            print("contact")
            let velocity = playerBody.velocity
            player.run(.applyImpulse(CGVector(dx: -velocity.dx / 4,
                                              dy: -velocity.dy / 4),
                                     duration: 2))
            playerBody.linearDamping = 1
        } else if let _ = contact.bodyB.node as? Player {
        }
    }
    
}

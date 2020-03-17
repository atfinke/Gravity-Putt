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
    
    let label = SKLabelNode(text: "Hole 1, +0")
    
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
    
    var _hole: Int = 1
    var _score: Int = 1
    var isDecellerating = false
    
    // MARK: - Initalization -
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        scene.scaleMode = .resizeFill
        return scene
    }
    
    override func didMove(to view: SKView) {
        setUpScene()
    }
    
    func setUpScene() {
        backgroundColor = SKColor(white: 0, alpha: 1)
        
        addChild(cameraNode)
        camera = cameraNode
        
        label.alpha = 0
        label.fontName = "Menlo-Regular"
        label.fontSize = 22
        cameraNode.addChild(label)
        
        label.position = CGPoint(x: 0, y: size.height / 2 - 30)
        
        player.position = CGPoint(x: -size.width / 2, y: 0)
        addChild(player)
        
        let startSize = CGSize(width: 200, height: 200)
        let initalLevel = Level(size: size, startSize: startSize)
        initalLevel.createPlanets(avoiding: [])
        initalLevel.goalNode.update(color: .green)
        initalLevel.position = CGPoint(x: -startSize.height / 2,
                                       y: -initalLevel.startRectLocalSpace.origin.y - startSize.height / 2)
        
        let goalRectWorldSpaceX = initalLevel.position.x - initalLevel.goalRectLocalSpace.width / 2
        let goalRectWorldSpaceY = initalLevel.position.y - initalLevel.goalRectLocalSpace.height / 2
        let goalRectWorldSpace = initalLevel.goalRectLocalSpace.offsetBy(dx: goalRectWorldSpaceX,
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
        
        let level = Level(size: size, startSize: finalLevel.goalRectLocalSpace.size)
        let positionX = finalLevel.position.x
            + finalLevel.goalRectLocalSpace.origin.x
            - level.startRectLocalSpace.width / 2
            - level.startRectLocalSpace.minX
        let positionY = finalLevel.position.y
            + finalLevel.goalRectLocalSpace.origin.y
            - level.startRectLocalSpace.height / 2
            - level.startRectLocalSpace.minY
        
        let offsetX = finalLevel.position.x - positionX
        let offsetY = finalLevel.position.y - positionY
        let finalLevelPlanetSafeRectsLevelSpace = finalLevel.planetRectsLocalSpace.map { $0.offsetBy(dx: offsetX, dy: offsetY) }
        level.createPlanets(avoiding: finalLevelPlanetSafeRectsLevelSpace)
        
        level.position = CGPoint(x: positionX, y: positionY)
        
        let goalSafeOffsetX = level.position.x - level.goalRectLocalSpace.width / 2
        let goalSafeOffsetY = level.position.y - level.goalRectLocalSpace.height / 2
        let goalSafeWorldRect = level.goalRectLocalSpace.offsetBy(dx: goalSafeOffsetX,
                                                                      dy: goalSafeOffsetY)
        
        levels.append(level)
        goalRectsWorldSpace.append(goalSafeWorldRect)
        addChild(level)
    }
    
    func moveToLevel(at index: Int) {
        _hole += index
        
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
                levelToRemove.goalNode.update(color: .blue)
            } else {
                levelToRemove.removeFromParent()
            }
        }
        
        cameraNode.run(.move(to: position, duration: 1))
        for _ in 0..<index {
            addLevel()
        }
        resetPlayerPosition()
        
        label.alpha = 10
        let scale: CGFloat = 0.75
        label.text = "Hole \(_hole), +\(_score - _hole)"
//        label.run(.sequence([
////            .group([
////            .moveTo(y: 0, duration: 1),
////            .scale(to: 1, duration: 1)
////            ]),
////            .wait(forDuration: 1.0),
//            .group([
//            .moveTo(y: size.height / 2 - label.frame.height * scale, duration: 1),
//            .scale(to: scale, duration: 1)
//            ])
//        ]))
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
        
        _score += 1
        label.text = "Hole \(_hole), +\(_score - _hole)"
    }
    
    // MARK: - Player -
    
    func resetPlayerPosition() {
        guard let physicsBody = player.physicsBody, let level = levels.first else {
            fatalError()
        }
        
        physicsBody.fieldBitMask = SpriteCategory.none
        physicsBody.velocity = CGVector(dx: 0, dy: 0)
        physicsBody.isDynamic = false
        
        let startRectWorldSpace = level.startRectLocalSpace.offsetBy(dx: level.position.x,
                                                                     dy: level.position.y)
        player.position = CGPoint(x: startRectWorldSpace.minX + startRectWorldSpace.width / 2,
                                  y: startRectWorldSpace.minY + startRectWorldSpace.height / 2)
        
        playerNeedsPhysicsBodyDynamics = true
    }
    
    // MARK: - SKScene Overrides -
    
    override func update(_ currentTime: TimeInterval) {
        
        if isDecellerating {
            let velocity = player.physicsBody!.velocity
            player.physicsBody?.velocity = CGVector(dx: velocity.dx * 0.7, dy: velocity.dy * 0.7)
        }
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
//            cameraNode.run(.scale(to: 2, duration: 0.25))
            
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
                    physicsBody.velocity = CGVector(dx: velocity.dx * 0.7,
                                                    dy: velocity.dy * 0.7)
//                    print(dist)
                    if magnitude < 2 && dist < 4 {
                        moveToLevel(at: index + 1)
                    } else if magnitude < 20 {
                        physicsBody.velocity = CGVector(dx: velocity.dx * 0.7,
                        dy: velocity.dy * 0.7)
                        if dist < 5 {
                            levels[index].goalNode.gravityField.strength = 0.5
                        }
                        //                        levels[index].goalNode.gravityField.strength = 1
                    }
                    break
                }
            }
        }
    }
    
    override func didSimulatePhysics() {
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
        if let player = contact.bodyA.node as? Player, let _ = player.physicsBody, let goal = contact.bodyB.node as? Goal,
            goal != lastLevel?.goalNode {
            goal.gravityField.strength = 4.5
            print("contact")
            //            let velocity = playerBody.velocity
            //            player.run(.applyImpulse(CGVector(dx: -velocity.dx / 4,
            //                                              dy: -velocity.dy / 4),
            //                                     duration: 2))
            //            playerBody.linearDamping = 1
        } else if let goal = contact.bodyB.node as? Planet {
            print("pc   ")
        }
        
        isDecellerating = true
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        if let player = contact.bodyA.node as? Player, let _ = player.physicsBody, let goal = contact.bodyB.node as? Goal,
        goal != lastLevel?.goalNode {
        
            print("contacted")
        }
        isDecellerating = false
    }
    
}

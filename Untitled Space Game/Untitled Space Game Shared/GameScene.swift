//
//  GameScene.swift
//  Untitled Space Game Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

let PRETTY_COLORS = true

class GameScene: SKScene {
    
    // MARK: - Properties -
    
    let label = SKLabelNode(text: "")
    
    let aimAssist = AimAssist()
    let cameraNode = SKCameraNode()
    
    let player: Player = {
        let player = Player(radius: 5, color: .white)
        player.zRotation = -CGFloat.pi / 2
        player.zPosition = ZPosition.player.rawValue
        return player
    }()
    
    var lastLevel: Level2?
    var levels = [Level2]()
    var goalRectsWorldSpace = [SKCircleRect]()
    
    var playerNeedsPhysicsBodyDynamics = false
    
    var holeNumber = 1
    var holeScore = 0 {
        didSet {
            updateScoreLabel()
        }
    }
    var totalScore = 0 {
        didSet {
            updateScoreLabel()
        }
    }
    
    var playerPathNodes = [SKShapeNode]()
    var playerVelocityModifier: CGFloat = 1.0
    
    var starDepthLevelNodes = [[StarDepthNode]]()
    
    var planetContact: Planet?
    
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
        
        cameraNode.zPosition = ZPosition.hud.rawValue
        addChild(cameraNode)
        camera = cameraNode
        
        label.alpha = 1
        label.fontName = "Menlo-Regular"
        label.fontSize = 22
        updateScoreLabel()
        cameraNode.addChild(label)
        
        label.position = CGPoint(x: 0, y: size.height / 2 - 30)
        
        player.position = CGPoint(x: -size.width / 2, y: 0)
        addChild(player)
        
        let startSize = CGSize(width: 120, height: 120)
        let initalLevel = Level2(size: size, startRadius: 60, number: holeNumber)
        initalLevel.createPlanets(avoiding: [])
        initalLevel.position = CGPoint(x: -startSize.height / 2,
                                       y: -initalLevel.startRectLocalSpace.center.y)
        
        let goalRectWorldSpaceX = initalLevel.position.x
        let goalRectWorldSpaceY = initalLevel.position.y
        let goalRectWorldSpace = initalLevel.goalRectLocalSpace.offsetBy(dx: goalRectWorldSpaceX,
                                                                         dy: goalRectWorldSpaceY)
        goalRectsWorldSpace.append(goalRectWorldSpace)
        
        levels.append(initalLevel)
        addChild(initalLevel)
        
        let depthLevels = 20
        let radiusCountInterval = CGFloat(150 - 40) / CGFloat(depthLevels)
        let radiusDepthInterval = CGFloat(0.8 - 0.5) / CGFloat(depthLevels)
        
        for starDepthLevel in (0..<depthLevels).reversed() {
            let maxCount = 150 - Int(radiusCountInterval) * (depthLevels - starDepthLevel)
            let minRadius = 0.35 + radiusDepthInterval * CGFloat(starDepthLevel)
            let maxRadius = 0.5 + radiusDepthInterval * CGFloat(starDepthLevel)
            
            let starDepthNode = StarDepthNode(size: size * Int(2),
                                              countRange: 0..<maxCount,
                                              radiusRange: minRadius..<maxRadius)
            starDepthLevelNodes.append([starDepthNode])
            
            addChild(starDepthNode)
            starDepthNode.position = initalLevel.position
        }
        
        for _ in 0..<2 {
            addLevel()
        }
        moveToLevel(at: 0)
        
        aimAssist.alpha = 0.0
        addChild(aimAssist)
        
        physicsWorld.contactDelegate = self
    }
    
    // MARK: - Level Management -
    
    func updateScoreLabel() {
        label.text = "\(totalScore), +\(holeScore)"
    }
    
    func addLevel() {
        guard let finalLevel = levels.last else {
            fatalError()
        }
        
        let level = Level2(size: size,
                          startRadius: finalLevel.goalRectLocalSpace.radius,
                          number: holeNumber + levels.count)
        
        let positionX = finalLevel.position.x
            + finalLevel.goalRectLocalSpace.center.x
            - level.startRectLocalSpace.center.x
        let positionY = finalLevel.position.y
            + finalLevel.goalRectLocalSpace.center.y
            - level.startRectLocalSpace.center.y
        
        let offsetX = finalLevel.position.x - positionX
        let offsetY = finalLevel.position.y - positionY
        let finalLevelPlanetSafeRectsLevelSpace = finalLevel.planetRectsLocalSpace
            .map { $0.offsetBy(dx: offsetX, dy: offsetY) }
//        level.createPlanets(avoiding: finalLevelPlanetSafeRectsLevelSpace)
        
        level.position = CGPoint(x: positionX, y: positionY)
        
        let goalSafeOffsetX = level.position.x
        let goalSafeOffsetY = level.position.y
        let goalSafeWorldRect = level.goalRectLocalSpace.offsetBy(dx: goalSafeOffsetX,
                                                                  dy: goalSafeOffsetY)
        
        levels.append(level)
        goalRectsWorldSpace.append(goalSafeWorldRect)
        addChild(level)
    }
    
    func moveToLevel(at index: Int) {
        print("moveToLevel")
        holeNumber += index
        totalScore += holeScore
        holeScore = 0
        
        let timingFunction: ((Float) -> Float) = { time in
            if time < 0.5 {
                return 2.0 * time * time
            } else {
                return 1.0 - 2.0 * (time - 1.0) * (time - 1.0)
            }
        }
        
        if index > 0 {
            lastLevel = levels[index - 1]
        }
        
        let level = levels[index]
        let position = CGPoint(x: level.position.x + level.frame.size.width / 2,
                               y: level.position.y + level.frame.size.height / 2)
        
        goalRectsWorldSpace.removeFirst(index)
        let levelsToRemove = levels.prefix(index)
        levels.removeFirst(index)
        
        let levelMoveDuration: TimeInterval = 2.0
        
        for (levelToRemoveIndex, levelToRemove) in levelsToRemove.enumerated() {
            if levelToRemoveIndex == levelsToRemove.count - 1 {
                let goalNode = levelToRemove.goalNode
                goalNode.physicsBody = nil
                goalNode.gravityField.removeFromParent()
                goalNode.borderNode.removeAllActions()
                
                let initalColor = goalNode.borderNode.strokeColor
                let nextColor = goalNode.borderNode.strokeColor.withAlphaComponent(1)
                let finalColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.5)
                
                let currentRotation = levelToRemove.goalNode.borderNode.zRotation
                let minAmountToRotate = -CGFloat.pi * 5
                let estimatedNewRotation = currentRotation + minAmountToRotate
                
                let rotationRounding = -CGFloat.pi * (1 / 2)
                let rotationPadding = rotationRounding - estimatedNewRotation.truncatingRemainder(dividingBy: rotationRounding)
                let finalRotation = estimatedNewRotation + rotationPadding
                
                let action: SKAction = .group([
                    SKAction.scale(to: 0.5, duration: levelMoveDuration),
                    
                    SKAction.rotate(toAngle: finalRotation, duration: levelMoveDuration),
                    SKAction.sequence([
                        SKAction.customAction(withDuration: levelMoveDuration * (1 / 4), actionBlock: { _, time in
                            let percent = time / CGFloat(levelMoveDuration * (1 / 4))
                            let color = initalColor.lerp(color: nextColor, percent: percent)
                            goalNode.borderNode.strokeColor = color
                        }),
                        SKAction.customAction(withDuration: levelMoveDuration * (3 / 4), actionBlock: { _, time in
                            let percent = time / CGFloat(levelMoveDuration * (3 / 4))
                            let color = nextColor.lerp(color: finalColor, percent: percent)
                            goalNode.borderNode.strokeColor = color
                        }),
                    ])
                    
                ])
                action.timingFunction = timingFunction
                
                
                levelToRemove.goalNode.borderNode.run(action)
                levelToRemove.goalNode.innerNode.run(.group([
                    .fadeOut(withDuration: levelMoveDuration),
                    SKAction.scale(to: 0.5, duration: levelMoveDuration),
                    .rotate(toAngle: -finalRotation, duration: levelMoveDuration)
                ]))
                
                let emitter = SKEmitterNode(fileNamed: "goal.sks")!
                emitter.zPosition = ZPosition.goalParticleSystems.rawValue
                levelToRemove.goalNode.addChild(emitter)
                
            } else {
                levelToRemove.goalNode.gravityField.removeFromParent()
                levelToRemove.run(.sequence([
                    .wait(forDuration: levelMoveDuration),
                    .removeFromParent()
                ]))
            }
        }
        
        
        
        let action = SKAction.move(to: position, duration: levelMoveDuration)
        //        action.timingMode = .easeInEaseOut
        action.timingFunction = timingFunction
        
        
        
        cameraNode.run(action)
        let cameraOffset = position - cameraNode.position
        
        var starDepthsToAdd = [Int: StarDepthNode]()
        var starDepthsToRemove = [Int: StarDepthNode]()
        
        for (depthLevel, depthNodesAtLevel) in starDepthLevelNodes.enumerated() {
            let offset = cameraOffset.scaleComponents(by: 0.75 * CGFloat(depthLevel + 1) / CGFloat(starDepthLevelNodes.count))
            for (depthLevelNodeIndex, depthLevelNode) in depthNodesAtLevel.enumerated() {
                let newPosition = depthLevelNode.position + offset
                
                let action = SKAction.move(to: newPosition, duration: levelMoveDuration)
                action.timingFunction = timingFunction
                depthLevelNode.run(action)
                
                let cameraPaddedDistanceFromDepthNode = (position.x + size.width * 2) - (newPosition.x + depthLevelNode.frame.width)
                
                if cameraPaddedDistanceFromDepthNode > 0 && depthLevelNodeIndex == depthNodesAtLevel.count - 1 {
                    let starDepthNode = StarDepthNode(previousNode: depthLevelNode)
                    starDepthNode.position = CGPoint(x: newPosition.x + depthLevelNode.frame.width,
                                                     y: level.position.y)
                    addChild(starDepthNode)
                    starDepthsToAdd[depthLevel] = starDepthNode
                } else if cameraPaddedDistanceFromDepthNode > size.width * 2 && depthLevelNodeIndex == 0 {
                    starDepthsToRemove[depthLevel] = depthLevelNode
                }
                
            }
            
            for (key, value) in starDepthsToAdd {
                starDepthLevelNodes[key].append(value)
            }
            for (key, value) in starDepthsToRemove {
                starDepthLevelNodes[key].removeFirst()
                value.run(.sequence([
                    .wait(forDuration: levelMoveDuration),
                    .removeFromParent()
                ]))
            }
        }
        
        DispatchQueue.global().async {
            for _ in 0..<index {
                self.addLevel()
            }
        }
        resetPlayerPosition()
        
        label.text = "\(totalScore), +\(holeScore)"
        playerVelocityModifier = 1.0
        
        let currentColor = backgroundColor
        let nextColor = SKColor(hue: CGFloat.random(in: 220..<300) / 360,
                                saturation: 1,
                                brightness: 0.1,
                                alpha: 1.0)
        let backgroundAction: SKAction = .customAction(withDuration: levelMoveDuration, actionBlock: { _, time in
            let percent = time / CGFloat(levelMoveDuration)
            let color = currentColor.lerp(color: nextColor, percent: percent)
            self.backgroundColor = color
            print(color)
        })
        backgroundAction.timingFunction = timingFunction
        
        if PRETTY_COLORS {
            run(backgroundAction)
        }
        
    }
    
    // MARK: - Aiming -
    
    func setTargeting(startLocation: CGPoint) {
        aimAssist.updateTail(length: 0)
        aimAssist.position = startLocation
        aimAssist.run(.fadeIn(withDuration: 0.15))
    }
    
    func setTargeting(pullBackLocation: CGPoint) {
        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let angle = -atan2(pullBackLocation.x - aimAssist.position.x,
                           pullBackLocation.y - aimAssist.position.y)
        aimAssist.zRotation = angle + CGFloat.pi
        
        let bla = min(magnitude, 200)
        aimAssist.updateTail(length: bla)
    }
    
    func finishedTargeting(pullBackLocation: CGPoint) {
        resetPlayerPathNodes()
        
        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let mag: CGFloat = min(magnitude / 5, 200)
        
        let x = mag * -sin(aimAssist.zRotation)
        let y = mag * cos(aimAssist.zRotation)
        player.physicsBody?.fieldBitMask = SpriteCategory.player
        player.run(.applyImpulse(CGVector(dx: x, dy: y), duration: 0.5))
        aimAssist.run(.fadeOut(withDuration: 0.15))
        
        holeScore += 1
    }
    
    // MARK: - Player -
    
    func resetPlayerPosition() {
        guard let physicsBody = player.physicsBody, let level = levels.first else {
            fatalError()
        }
        
        planetContact = nil
        
        physicsBody.fieldBitMask = SpriteCategory.none
        physicsBody.velocity = CGVector(dx: 0, dy: 0)
        physicsBody.isDynamic = false
        
        let startRectWorldSpace = level.startRectLocalSpace.offsetBy(dx: level.position.x,
                                                                     dy: level.position.y)
        player.position = startRectWorldSpace.center
        
        playerNeedsPhysicsBodyDynamics = true
        playerVelocityModifier = 1.0
        
        resetPlayerPathNodes()
    }
    
    // MARK: - SKScene Overrides -
    
    func resetPlayerPathNodes() {
        lastPoint = CGPoint.zero
        
        for (index, node) in playerPathNodes.enumerated() {
            let action = SKAction.sequence([
                .wait(forDuration: 0.02 * TimeInterval(index)),
                .fadeOut(withDuration: 0.5),
                .removeFromParent()
            ])
            node.run(action)
        }
        
        playerPathNodes = []
    }
    
    var lastPoint = CGPoint.zero
    
    override func update(_ currentTime: TimeInterval) {
        guard let physicsBody = player.physicsBody else {
            fatalError()
        }
        
        let playerVelocity = physicsBody.velocity
        let playerVelocityMagnitude = playerVelocity.magnitude()
        
        if playerVelocityMagnitude > 0.01 && player.position.distance(to: lastPoint) > 15 {
            lastPoint = player.position
            
            let playerPathNode = SKShapeNode(circleOfRadius: 2)
            playerPathNode.fillColor = .white
            playerPathNode.position = lastPoint
            addChild(playerPathNode)
            
            playerPathNodes.append(playerPathNode)
        }
        
        if playerVelocityModifier != 1.0 {
            physicsBody.velocity = CGVector(dx: playerVelocity.dx * playerVelocityModifier,
                                            dy: playerVelocity.dy * playerVelocityModifier)
        }
        
        if let level = levels.first {
            let safeWidthPadding: CGFloat = size.width / 10
            let levelMinXWorldSpace = level.position.x - size.width / 2 + safeWidthPadding
            let levelMaxXWorldSpace = level.position.x + size.width / 2 - safeWidthPadding
            
            let safeHeightPadding: CGFloat = size.height / 10
            let levelMinYWorldSpace = level.position.y - size.height / 2 + safeHeightPadding
            let levelMaxYWorldSpace = level.position.y + size.height / 2 - safeHeightPadding
            
            var scale: CGFloat = 1.0
            if player.position.x > levelMaxXWorldSpace {
                scale = max(scale, 1.0 + (player.position.x - levelMaxXWorldSpace) / (size.width / 2))
            } else if player.position.x < levelMinXWorldSpace {
                scale = max(scale, 1.0 + (levelMinXWorldSpace - player.position.x) / (size.width / 2))
            }
            
            if player.position.y > levelMaxYWorldSpace {
                scale = max(scale, 1.0 + (player.position.y - levelMaxYWorldSpace) / (size.height / 2))
            } else if player.position.y < levelMinYWorldSpace {
                scale = max(scale, 1.0 + (levelMinYWorldSpace - player.position.y) / (size.height / 2))
            }
            
            cameraNode.run(.scale(to: min(scale, 2), duration: 0.25))
//            cameraNode.run(.scale(to: 5, duration: 0.25))

            if scale > 2.5 {
                resetPlayerPosition()
            }
        }
        
        for (index, goalRect) in goalRectsWorldSpace.enumerated() {
            let dist = goalRect.center.distance(to: player.position)
            
            if dist < goalRect.radius * 2 {
                levels[index].goalNode.label.alpha = (dist - 10) / (goalRect.radius * 2)
            }
            
            if dist < goalRect.radius * 1.5 {
                levels[index].goalNode.gravityField.strength = 0.2
                
                if playerVelocityMagnitude < 1 && dist < 2 {
                    moveToLevel(at: index + 1)
                } else if dist < 5 {
                    playerVelocityModifier = 0.8
                } else if playerVelocityMagnitude < 50 {
                    playerVelocityModifier = 0.9
                }
                break
            }
        }
        
//        if let p = planetContact, playerVelocityMagnitude < 20 {
//            print("resting planet")
//            resetPlayerPathNodes()
//            planetContact?.gravityField.strength = 0.2
//            playerVelocityModifier = 0.5
//            p.gravityField.isExclusive = true
//        }
        
        //        cameraNode.run(.scale(to: 2, duration: 0.1))
    }
    
    func move(x: CGFloat, y: CGFloat) {
        
        cameraNode.run(.moveBy(x: x, y: y, duration: 0.1))
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
            playerVelocityModifier = 0.9
        } else if let _ = contact.bodyA.node as? Planet {
            playerVelocityModifier = 0.95
            print("hitting planet")
        } else if let b = contact.bodyB.node as? Planet {
            playerVelocityModifier = 0.95
            print("hitting planetB")
            planetContact = b
            
        }
    }
    
    func didEnd(_ contact: SKPhysicsContact) {
        playerVelocityModifier = 1.0
        print("contact ended")
        
//        if let p = planetContact {
//            p.removeAllActions()
//            let duration: TimeInterval = 2
//            p.run(.sequence([
//                .wait(forDuration: 0.2),
//                .customAction(withDuration: duration, actionBlock: { _, time in
//                    let percent = time / CGFloat(duration)
//                    p.gravityField.strength = Float(0.1 + (1.5 - 0.1) * (percent))
//                    
//                })
//            
//            ]))
//        }
//        planetContact = nil
    }
    
}

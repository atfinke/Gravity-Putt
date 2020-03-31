//
//  GameScene.swift
//  Untitled Space Game Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

let PRETTY_COLORS = false

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

    var lastLevel: Level?
    var levels = [Level]()
    var goalRectsWorldSpace = [CGRect]()

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

    var playerPath = CGMutablePath()
    var playerPathShape: SKShapeNode?

    var playerVelocityModifier: CGFloat = 1.0

    var starDepthLevelNodes = [[StarDepthNode]]()

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
        let initalLevel = Level(size: size, startSize: startSize, num: holeNumber)
        initalLevel.createPlanets(avoiding: [])
        initalLevel.position = CGPoint(x: -startSize.height / 2,
                                       y: -initalLevel.startRectLocalSpace.origin.y - startSize.height / 2)

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

        playerPath.move(to: player.position)

        let playerPathShape = SKShapeNode(path: playerPath)
        playerPathShape.strokeColor = .white
        playerPathShape.lineWidth = 6
        addChild(playerPathShape)
        self.playerPathShape = playerPathShape
    }

    // MARK: - Level Management -

    func updateScoreLabel() {
        label.text = "\(totalScore), +\(holeScore)"
    }

    func addLevel() {
        guard let finalLevel = levels.last else {
            fatalError()
        }

        let level = Level(size: size,
                          startSize: finalLevel.goalRectLocalSpace.size,
                          num: holeNumber + levels.count)

        let positionX = finalLevel.position.x
            + finalLevel.goalRectLocalSpace.midX
            - level.startRectLocalSpace.midX
        let positionY = finalLevel.position.y
            + finalLevel.goalRectLocalSpace.midY
            - level.startRectLocalSpace.midY

        let offsetX = finalLevel.position.x - positionX
        let offsetY = finalLevel.position.y - positionY
        let finalLevelPlanetSafeRectsLevelSpace = finalLevel.planetRectsLocalSpace
            .map { $0.offsetBy(dx: offsetX, dy: offsetY) }
        level.createPlanets(avoiding: finalLevelPlanetSafeRectsLevelSpace)

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

        if index > 0 {
            lastLevel = levels[index - 1]
        }

        let level = levels[index]
        let position = CGPoint(x: level.position.x + level.frame.size.width / 2,
                               y: level.position.y + level.frame.size.height / 2)

        goalRectsWorldSpace.removeFirst(index)
        let levelsToRemove = levels.prefix(index)
        levels.removeFirst(index)

        let levelMoveDuration: TimeInterval = 1.0

        for (levelToRemoveIndex, levelToRemove) in levelsToRemove.enumerated() {
            if levelToRemoveIndex == levelsToRemove.count - 1 {
                let goalNode = levelToRemove.goalNode
                goalNode.physicsBody = nil
                goalNode.gravityField.removeFromParent()
                goalNode.borderNode.removeAllActions()

                let currentColor = goalNode.borderNode.strokeColor

                let currentRotation = levelToRemove.goalNode.borderNode.zRotation
                let minAmountToRotate = -CGFloat.pi * 3
                let estimatedNewRotation = currentRotation + minAmountToRotate

                let rotationRounding = -CGFloat.pi * (1 / 4)
                let rotationPadding = rotationRounding - estimatedNewRotation.truncatingRemainder(dividingBy: rotationRounding)
                let finalRotation = estimatedNewRotation + rotationPadding

                let finalColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.5)

                let action: SKAction = .group([
                    .scale(to: 0.5, duration: levelMoveDuration),
                    .customAction(withDuration: levelMoveDuration, actionBlock: { _, time in
                        let percent = time / CGFloat(levelMoveDuration)
                        let color = currentColor.lerp(color: finalColor, percent: percent)
                        goalNode.borderNode.strokeColor = color
                    }),
                    .rotate(toAngle: finalRotation, duration: levelMoveDuration),
                    .fadeAlpha(to: 0.25, duration: levelMoveDuration)
                ])
                action.timingMode = .easeInEaseOut
                levelToRemove.goalNode.borderNode.run(action)
                levelToRemove.goalNode.innerNode.run(.group([
                    .fadeOut(withDuration: levelMoveDuration),
                    .scale(to: 0, duration: levelMoveDuration)
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
        action.timingMode = .easeInEaseOut
        cameraNode.run(action)
        let cameraOffset = position - cameraNode.position

        var starDepthsToAdd = [Int: StarDepthNode]()
        var starDepthsToRemove = [Int: StarDepthNode]()

        for (depthLevel, depthNodesAtLevel) in starDepthLevelNodes.enumerated() {
            let offset = cameraOffset.scaleComponents(by: 0.75 * CGFloat(depthLevel + 1) / CGFloat(starDepthLevelNodes.count))
            for (depthLevelNodeIndex, depthLevelNode) in depthNodesAtLevel.enumerated() {
                let newPosition = depthLevelNode.position + offset

                let action = SKAction.move(to: newPosition, duration: levelMoveDuration)
                action.timingMode = .easeInEaseOut
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

        for _ in 0..<index {
            addLevel()
        }
        resetPlayerPosition()

        label.text = "\(totalScore), +\(holeScore)"
        playerVelocityModifier = 1.0

        let currentColor = backgroundColor
        let nextColor = SKColor(deviceHue: CGFloat.random(in: 200..<360) / 360,
                saturation: 1,
                brightness: 0.3,
                alpha: 1.0)
        let backgroundAction: SKAction = .customAction(withDuration: levelMoveDuration, actionBlock: { _, time in
            let percent = time / CGFloat(levelMoveDuration)
            let color = currentColor.lerp(color: nextColor, percent: percent)
            self.backgroundColor = color
        })
        backgroundAction.timingMode = .easeInEaseOut

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
        aimAssist.updateTail(length: magnitude)
    }

    func finishedTargeting(pullBackLocation: CGPoint) {
        playerPath = CGMutablePath()
        playerPath.move(to: player.position)

        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let mag: CGFloat = magnitude / 5
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

        physicsBody.fieldBitMask = SpriteCategory.none
        physicsBody.velocity = CGVector(dx: 0, dy: 0)
        physicsBody.isDynamic = false

        let startRectWorldSpace = level.startRectLocalSpace.offsetBy(dx: level.position.x,
                                                                     dy: level.position.y)
        player.position = startRectWorldSpace.center

        playerNeedsPhysicsBodyDynamics = true
        playerVelocityModifier = 1.0

        playerPath = CGMutablePath()
        playerPath.move(to: player.position)
        playerPathShape?.path = playerPath.copy(dashingWithPhase: 0, lengths: [12])
    }

    // MARK: - SKScene Overrides -

    override func update(_ currentTime: TimeInterval) {
        guard let physicsBody = player.physicsBody else {
            fatalError()
        }

        let playerVelocity = physicsBody.velocity
        let playerVelocityMagnitude = playerVelocity.magnitude()

        if playerVelocityMagnitude > 0.01 {
            playerPath.addLine(to: player.position)
            playerPathShape?.path = playerPath.copy(dashingWithPhase: 0, lengths: [12])
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

            if scale > 2.5 {
                resetPlayerPosition()
            }
        }

        for (index, goalRect) in goalRectsWorldSpace.enumerated() {
            let goalCenter = CGPoint(x: goalRect.midX, y: goalRect.midY)
            let dist = goalCenter.distance(to: player.position)

            if dist < 60 {
                levels[index].goalNode.innerNode.alpha = (dist - 10) / 50
            }

            if dist < 40 {
                levels[index].goalNode.gravityField.strength = 0.2

                if playerVelocityMagnitude < 2 && dist < 4 {
                    moveToLevel(at: index + 1)
                } else if playerVelocityMagnitude < 50 {
                    playerVelocityModifier = 0.94
                }
                break
            }
        }

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
            playerVelocityModifier = 0.75
        } else if let _ = contact.bodyA.node as? Planet {
            playerVelocityModifier = 0.95
        }
    }

    func didEnd(_ contact: SKPhysicsContact) {
        playerVelocityModifier = 1.0
    }

}

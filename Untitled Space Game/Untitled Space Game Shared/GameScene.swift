//
//  GameScene.swift
//  Untitled Space Game Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class GameScene: SKScene, Codable {

    enum CodingKeys: String, CodingKey {
        case cameraNodePosition
        case lastLevel
        case levels

         case holeNumber
         case holeScore
         case totalScore
    }

    // MARK: - Properties -

    let cameraNode = SKCameraNode()
    let statusLabel = SKLabelNode(text: "")

    let aimAssist = AimAssist()

    var restingOnPlanet: Planet?
    var isPerformingOffscreenReset = false
    var isPlayerReadyForHit = true {
        didSet {
            let white: CGFloat = isPlayerReadyForHit ? 1.0 : 0.5
            aimAssist.update(color: SKColor(white: white, alpha: 1.0))
        }
    }
    var playerNeedsPhysicsBodyDynamics = false
    var playerVelocityModifier: CGFloat = 1.0
    let player: Player = {
        let player = Player(radius: Design.playerRadius)
        player.zRotation = -CGFloat.pi / 2
        return player
    }()

    var playerPathNodes = [SKSpriteNode]()
    var playerPathLastPosition: CGPoint?
    let playerPathTexture = CircleRenderer.create(radius: Design.playerPathNodeRadius)

    var levels = [LevelNode]()
    var lastLevel: LevelNode?
    var activeLevelGoalNode: Goal?
    var activeLevelGoalNodeWorldSpace: SKCircleRect?
    var planetNodesWorldSpace = [[Planet: SKCircleRect]]()

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

    var starDepthLevelNodes = [[StarDepthNode]]()
    var contactGoal: Goal?
    var contactPlanet: Planet? {
        didSet {
            oldValue?.gravityField.isExclusive = false
            contactPlanet?.gravityField.isExclusive = true
        }
    }

    // MARK: - Level Management -

    func updateScoreLabel() {
        statusLabel.text = "\(totalScore), +\(holeScore)"
    }

    func addLevel() {
        guard let finalLevel = levels.last else {
            fatalError()
        }

        let level = LevelNode(size: size, number: holeNumber + levels.count)
        level.goalNode.gravityField.isEnabled = false

        let positionX = finalLevel.position.x
            + finalLevel.goalRectLocalSpace.center.x
            - level.startRectLocalSpace.center.x
        let positionY = finalLevel.position.y
            + finalLevel.goalRectLocalSpace.center.y
            - level.startRectLocalSpace.center.y
        level.position = CGPoint(x: positionX, y: positionY)

        levels.append(level)
        addChild(level)

        var adjusted = [Planet: SKCircleRect]()
        level.localSpacePlanets.forEach { adjusted[$0.key] = $0.value.offsetBy(dx: positionX,
                                                                               dy: positionY)}
        planetNodesWorldSpace.append(adjusted)
    }

    func moveToNextLevel(isFirstLevel: Bool = false) {
        let transitionDuration = Design.levelTransitionDuration
        let transitionTiming = Design.levelTransitionTimingFunction

        // Adjust score
        holeNumber += 1
        totalScore += holeScore
        holeScore = 0
        updateScoreLabel()

        // Remove the last last level (that was kept in case the user hits backwards)
        let removeAfterTransitionAction: SKAction = .remove(after: transitionDuration)
        if let lastLevel = lastLevel {
            lastLevel.run(removeAfterTransitionAction)
            planetNodesWorldSpace.removeFirst()
        }
        if !isFirstLevel {
            lastLevel = levels.removeFirst()
        }

        // Last Goal Animation
        if let newLastLevel = lastLevel {
            let goalNode = newLastLevel.goalNode
            goalNode.physicsBody = nil
            goalNode.gravityField.removeFromParent()
            goalNode.borderNode.removeAllActions()

            let initalColor = goalNode.borderNode.strokeColor
            let nextColor = goalNode.borderNode.strokeColor.withAlphaComponent(1)
            let finalColor = SKColor(red: 1, green: 1, blue: 1, alpha: 0.5)
            let initalColorChangeDuration = Design.levelTransitionDuration * (1 / 4)
            let nextColorChangeDuration = Design.levelTransitionDuration * (3 / 4)

            let currentRotation = goalNode.borderNode.zRotation
            let minAmountToRotate = -CGFloat.pi * 5
            let estimatedNewRotation = currentRotation + minAmountToRotate

            let rotationRounding = -CGFloat.pi * (1 / 2)
            let rotationPadding = rotationRounding - estimatedNewRotation.truncatingRemainder(dividingBy: rotationRounding)
            let finalRotation = estimatedNewRotation + rotationPadding

            let scaleFactor: CGFloat = 0.5

            let lastGoalBorderAction: SKAction = .group([
                .scale(to: scaleFactor, duration: transitionDuration),
                .rotate(toAngle: finalRotation, duration: transitionDuration),
                .sequence([
                    .customAction(withDuration: initalColorChangeDuration, actionBlock: { _, time in
                        let percent = time / CGFloat(initalColorChangeDuration)
                        let color = initalColor.lerp(color: nextColor, percent: percent)
                        goalNode.borderNode.strokeColor = color
                    }),
                    .customAction(withDuration: nextColorChangeDuration, actionBlock: { _, time in
                        let percent = time / CGFloat(nextColorChangeDuration)
                        let color = nextColor.lerp(color: finalColor, percent: percent)
                        goalNode.borderNode.strokeColor = color
                    })
                ])
            ])
            lastGoalBorderAction.timingFunction = transitionTiming

            let lastGoalInnerAction: SKAction = .group([
                .fadeOut(withDuration: transitionDuration),
                .scale(to: scaleFactor, duration: transitionDuration),
                .rotate(toAngle: -finalRotation, duration: transitionDuration)
            ])
            lastGoalInnerAction.timingFunction = transitionTiming

            goalNode.borderNode.run(lastGoalBorderAction)
            goalNode.innerNode.run(lastGoalInnerAction)
        }

        // Update the new level variables
        let newActiveLevel = levels[0]
        let newActiveGoal = newActiveLevel.goalNode
        newActiveGoal.gravityField.isEnabled = true
        activeLevelGoalNode = newActiveGoal

        let cameraPosition = CGPoint(x: newActiveLevel.position.x + newActiveLevel.frame.size.width / 2,
                               y: newActiveLevel.position.y + newActiveLevel.frame.size.height / 2)

        let goalSafeOffsetX = newActiveLevel.position.x
        let goalSafeOffsetY = newActiveLevel.position.y
        activeLevelGoalNodeWorldSpace = newActiveLevel.goalRectLocalSpace.offsetBy(dx: goalSafeOffsetX,
                                                                                   dy: goalSafeOffsetY)

        // Fade in new goal
        let goalAlphaAction: SKAction = .sequence([
            .wait(forDuration: transitionDuration - 0.5),
            .fadeIn(withDuration: 0.75)
        ])
        goalAlphaAction.timingMode = .easeInEaseOut
        newActiveGoal.run(goalAlphaAction)

        // Move camera
        let cameraPositionAction = SKAction.move(to: cameraPosition, duration: transitionDuration)
        cameraPositionAction.timingFunction = transitionTiming
        cameraNode.run(cameraPositionAction)

        let cameraOffset = cameraPosition - cameraNode.position
        updateDepthNodes(forCameraPosition: cameraPosition, offset: cameraOffset)

        if Design.colors {
            let currentColor = backgroundColor
            let nextColor = SKColor(hue: CGFloat.random(in: 220..<300) / 360,
                                    saturation: 1,
                                    brightness: 0.1,
                                    alpha: 1.0)
            let backgroundAction: SKAction = .customAction(withDuration: transitionDuration, actionBlock: { _, time in
                let percent = time / CGFloat(transitionDuration)
                let color = currentColor.lerp(color: nextColor, percent: percent)
                self.backgroundColor = color
            })
            backgroundAction.timingFunction = transitionTiming
            run(backgroundAction)
        }

        // Player updates
        resetPlayerPosition()
        playerVelocityModifier = 1.0

        DispatchQueue.global(qos: .userInitiated).async {
            self.addLevel()
        }

        
//
//        do {
//            try str?.write(to: filename, atomically: true, encoding: String.Encoding.utf8)
//        } catch {
//            // failed to write file – bad permissions, bad filename, missing permissions, or more likely it can't be converted to the encoding
//        }
//        print(str)
//        print(123)
        try! save()
    }
    
    func save() throws {
        let data = try JSONEncoder().encode(self)
        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("data")
        try data.write(to: url)
    }

    // MARK: - Aiming -

    func setTargeting(startLocation: CGPoint) {
        aimAssist.update(tailLength: 0)
        aimAssist.position = startLocation
        aimAssist.run(.fadeIn(withDuration: 0.15))
    }

    func setTargeting(pullBackLocation: CGPoint) {
        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let angle = -atan2(pullBackLocation.x - aimAssist.position.x,
                           pullBackLocation.y - aimAssist.position.y)
        aimAssist.zRotation = angle + CGFloat.pi

        let length = min(magnitude, 200)
        aimAssist.update(tailLength: length)
    }

    func finishedTargeting(pullBackLocation: CGPoint) {
        aimAssist.run(.fadeOut(withDuration: 0.15))

        guard isPlayerReadyForHit, let physicsBody = player.physicsBody else { return }

        resetPlayerPathNodes()

        if let planet = contactPlanet {
            let initalStrength = Design.planetFieldStrength / 100
            planet.gravityField.strength = initalStrength

            let duration: TimeInterval = 1.5
            let action: SKAction = .customAction(withDuration: duration, actionBlock: { _, time in
                let progress = Float(time) / Float(duration)
                let strength = initalStrength + (Design.planetFieldStrength - initalStrength) * progress
                planet.gravityField.strength = strength
            })
            planet.run(action)
            contactPlanet = nil
        }

        let magnitude = pullBackLocation.distance(to: aimAssist.position)
        let mag: CGFloat = max(min(magnitude / 5, 200), 5)

        let x = mag * -sin(aimAssist.zRotation)
        let y = mag * cos(aimAssist.zRotation)

        player.run(.applyImpulse(CGVector(dx: x, dy: y), duration: 0.5))

        let action: SKAction = .sequence([
            .wait(forDuration: 0.2),
            .run {
                physicsBody.fieldBitMask = SpriteCategory.player
                physicsBody.collisionBitMask = SpriteCategory.player
            }
        ])
        player.run(action)

        holeScore += 1

        isPlayerReadyForHit = false
    }

    // MARK: - Player -

    func resetPlayerPosition(to position: CGPoint? = nil) {
        guard let physicsBody = player.physicsBody, let level = levels.first else {
            fatalError()
        }

        contactPlanet = nil
        contactGoal = nil

        physicsBody.fieldBitMask = SpriteCategory.none
        physicsBody.collisionBitMask = SpriteCategory.none
        physicsBody.velocity = CGVector(dx: 0, dy: 0)
        physicsBody.isDynamic = false

        if let position = position {
            player.position = position
        } else {
            let startRectWorldSpace = level.startRectLocalSpace.offsetBy(dx: level.position.x,
                                                                         dy: level.position.y)
            player.position = startRectWorldSpace.center
        }

        playerNeedsPhysicsBodyDynamics = true
        playerVelocityModifier = 1.0

        resetPlayerPathNodes()
        isPlayerReadyForHit = true
    }

    func resetPlayerPathNodes() {
        for (index, node) in playerPathNodes.enumerated() {
            let action = SKAction.sequence([
                .wait(forDuration: 0.02 * TimeInterval(index)),
                .fadeOut(withDuration: 0.5),
                .removeFromParent()
            ])
            node.run(action)
        }

        playerPathNodes = []
        playerPathLastPosition = nil
    }

    func updateCamera() {
        guard let level = levels.first else { return }
        // Camera scale

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

        let maxScale: CGFloat = 1.5
        cameraNode.run(.scale(to: min(scale, maxScale), duration: 0.25))
        if scale > maxScale && !isPerformingOffscreenReset {
            isPerformingOffscreenReset = true
            let resetAction: SKAction = .sequence([
                .wait(forDuration: 1.0),
                .run {
                    self.resetPlayerPosition(to: nil)
                },
                .run {
                    self.isPerformingOffscreenReset = false
                }
            ])
            run(resetAction, withKey: "resetAction")
        } else if scale <= maxScale && isPerformingOffscreenReset {
            removeAction(forKey: "resetAction")
        }

    }

    // MARK: - SKScene Overrides -

    override func update(_ currentTime: TimeInterval) {
        guard let physicsBody = player.physicsBody else {
            fatalError()
        }

        updateCamera()

        guard physicsBody.fieldBitMask == SpriteCategory.player else {
            return
        }

        let playerVelocity = physicsBody.velocity
        let playerVelocityMagnitude = playerVelocity.magnitude()

        // Player path viz
        if playerVelocityMagnitude > 0.01 {
            var newPoint: CGPoint?

            if let lastPoint = playerPathLastPosition {
                let diffX = player.position.x - lastPoint.x
                let diffY = player.position.y - lastPoint.y
                let diffMag = sqrt(pow(diffX, 2) + pow(diffY, 2))

                let spacing = Design.playerPathSpacing

                let projectedPoint = CGPoint(x: diffX / diffMag * spacing + lastPoint.x,
                                             y: diffY / diffMag * spacing + lastPoint.y)
                if player.position.distance(to: lastPoint) > spacing {
                    newPoint = projectedPoint
                }
            } else {
                newPoint = player.position
            }

            if let newPoint = newPoint {
                playerPathLastPosition = newPoint

                let playerPathNode = SKSpriteNode(texture: playerPathTexture)
                playerPathNode.position = newPoint
                playerPathNode.zPosition = ZPosition.playerPath.rawValue
                playerPathNode.alpha = 0.5
                addChild(playerPathNode)

                playerPathNodes.append(playerPathNode)
            }
        }

        // Modify player velocity
        if playerVelocityModifier != 1.0 {
            physicsBody.velocity = CGVector(dx: playerVelocity.dx * playerVelocityModifier,
                                            dy: playerVelocity.dy * playerVelocityModifier)
        }

        if contactPlanet == nil && Debugging.isPlanetInteractionOn {
            for levelPlanetNodesWorldSpace in planetNodesWorldSpace {
                for item in levelPlanetNodesWorldSpace {
                    let rect = item.value
                    let distance = rect.center.distance(to: player.position) - Design.playerRadius
                    if distance - rect.radius < 1 {
                        contactPlanet = item.key
                        print(1)
                        break
                    }
                }
            }
        }
//            print(playerVelocityMagnitude)
        var newPlayerVelocityModifier: CGFloat = 1
        if let planet = contactPlanet {
            newPlayerVelocityModifier = 0.9
            if playerVelocityMagnitude < 2 {
                resetPlayerPosition(to: player.position)
                restingOnPlanet = planet
                return
            }
        }

        guard let goalNode = activeLevelGoalNode,
            let goalRect = activeLevelGoalNodeWorldSpace else {
                return
        }

        let dist = goalRect.center.distance(to: player.position) - Design.playerRadius

        if dist < goalRect.radius * 2 {
            goalNode.label.alpha = (dist - 10) / (goalRect.radius * 2)
        } else {
            goalNode.label.alpha = 1
        }

        if dist < goalRect.radius * 1.5 {
            goalNode.gravityField.isExclusive = true
            goalNode.gravityField.strength = 4.25

            if playerVelocityMagnitude < 1 && dist < 2 {
                moveToNextLevel()
            } else if dist < goalRect.radius / 5 {
                newPlayerVelocityModifier = 0.48
                goalNode.gravityField.strength = 0.25
            } else {
                newPlayerVelocityModifier = 0.69
            }
        } else {
            goalNode.gravityField.isExclusive = false
            goalNode.gravityField.strength = Design.goalFieldStrength
        }

        playerVelocityModifier = newPlayerVelocityModifier
    }

    override func didSimulatePhysics() {
        if playerNeedsPhysicsBodyDynamics {
            playerNeedsPhysicsBodyDynamics = false
            player.physicsBody?.isDynamic = true
        }
    }

    // MARK: - Debug -

    func debugMove(x: CGFloat, y: CGFloat) {
        #if DEBUG
        cameraNode.run(.moveBy(x: x, y: y, duration: 0.1))
        #endif
    }
//
//    enum CodingKeys: String, CodingKey {
//           case cameraNodePosition
//           case lastLevel
//           case levels
//
//            case holeNumber
//            case holeScore
//            case totalScore
//       }
    public func encode(to encoder: Encoder) throws {
//        let (r, g, b, a) = color.rgba()
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastLevel, forKey: .lastLevel)
        try container.encode(levels, forKey: .levels)
        
        try container.encode(holeNumber, forKey: .holeNumber)
        try container.encode(holeScore, forKey: .holeScore)
        try container.encode(totalScore, forKey: .totalScore)
    }
    
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        
        
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.lastLevel = try? values.decode(LevelNode.self, forKey: .lastLevel)
        self.levels = try values.decode([LevelNode].self, forKey: .levels)
         
        self.holeNumber = try values.decode(Int.self, forKey: .holeNumber)
        self.holeScore = try values.decode(Int.self, forKey: .holeScore)
        self.totalScore = try values.decode(Int.self, forKey: .totalScore)
        
        for level in levels {
            addChild(level)
        }
        moveToNextLevel(isFirstLevel: true)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: size)
    }
    
    override init() {
        super.init()
        scaleMode = .resizeFill
    }
}

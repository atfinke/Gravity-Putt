//
//  GameScene.swift
//  Gravity Golf Shared
//
//  Created by Andrew Finke on 3/13/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit
import StoreKit

class GameScene: SKScene, Codable {
    
    // MARK: - Types -
    
    enum CodingKeys: String, CodingKey {
        case lastLevel
        case levels
        case gameStats
    }
    
    // MARK: - Properties -
    
    // Nodes
    let aimAssist = AimAssist()
    let cameraNode = SKCameraNode()
    let strokesLabel = SKLabelNode()
    let holeLabel = SKLabelNode()
    let introLabel = SKLabelNode()
    let leaderboardButton = LeaderboardButton()
    let backgroundColorNode = SKSpriteNode(color: .white, size: CGSize(width: 10, height: 10))
    
    let unlockLevelsNode = UnlockLevelsNode()
    var starDepthNodes = [[StarDepthNode]]()
    var restingOnPlanet: Planet?
    var contactPlanet: Planet? {
        didSet {
            oldValue?.gravityField.isExclusive = false
            contactPlanet?.gravityField.isExclusive = true
        }
    }
    
    // Player
    var isOffscreenResetQueued = false
    var isPerformingOffscreenReset = false
    var isPlayerReadyForHit = true {
        didSet {
            let alpha: CGFloat = isPlayerReadyForHit ? 1.0 : 0.5
            aimAssist.update(componentAlphas: alpha)
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
    
    // Levels
    var levelSize: CGSize = .zero
    var levels = [LevelNode]()
    var lastLevel: LevelNode?
    var activeLevelGoalNode: Goal?
    var activeLevelGoalNodeWorldSpace: SKCircleRect?
    var planetNodesWorldSpace = [[Planet: SKCircleRect]]()
    let workQueue = DispatchQueue(label: "com.andrewfinke.create", qos: .userInitiated)
    
    // Other
    var leaderboardRect = CGRect()
    var holeDurationTimer: Timer?
    
    var gameStats = GameStats()
    let leaderboardUtility = LeaderboardUtility()
    let hapticsUtility = HapticsUtility()
    
    var presentingController: SKController? {
        didSet {
            guard let presentingSize = presentingController?.view.frame.size else { fatalError() }
            let usableHeight = size.width / presentingSize.width * presentingSize.height
            levelSize = CGSize(width: size.width, height: usableHeight)
        }
    }
    let store = Store()
    
    // MARK: - Initalization -
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(size: CGSize) {
        super.init(size: CGSize(width: 1000, height: 800))
    }
    
    override init() {
        super.init()
        scaleMode = .aspectFill
        store.unlockStateUpdated = { success in
            DispatchQueue.main.async {
                if self.unlockLevelsNode.parent != nil {
                    let action: SKAction = .sequence([
                        .fadeOut(withDuration: 0.15),
                        .removeFromParent()
                    ])
                    self.unlockLevelsNode.run(action)
                }
            }
        }
    }
    
    required public convenience init(from decoder: Decoder) throws {
        self.init()
        
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.lastLevel = try? values.decode(LevelNode.self, forKey: .lastLevel)
        self.levels = try values.decode([LevelNode].self, forKey: .levels)
        self.gameStats = try values.decode(GameStats.self, forKey: .gameStats)
        
        if let level = lastLevel {
            addChild(level)
        }
        
        for level in levels {
            addChild(level)
            
            var adjusted = [Planet: SKCircleRect]()
            level.localSpacePlanets.forEach { adjusted[$0.key] = $0.value.offset(by: level.position) }
            planetNodesWorldSpace.append(adjusted)
        }
        moveToNextLevel(isFirstLevel: true, duration: nil)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(lastLevel, forKey: .lastLevel)
        try container.encode(levels, forKey: .levels)
        try container.encode(gameStats, forKey: .gameStats)
    }
    
    // MARK: - Setup -
    
    func setupScene() {
        setupCamera()
        
        backgroundColorNode.color = .randomBackgroundColor
        backgroundColorNode.xScale = size.width / 10 * 2
        backgroundColorNode.yScale = size.height / 10 * 2
        backgroundColorNode.zPosition = ZPosition.background.rawValue
        backgroundColorNode.position = cameraNode.position
        addChild(backgroundColorNode)
        
        if gameStats.holeNumber == 1 {
            introLabel.numberOfLines = 2
            introLabel.color = .white
            introLabel.attributedText = NSAttributedString.stylized(string: "Gravity\nGolf",
                                                               size: 40,
                                                               weight: .semibold)
            introLabel.position = CGPoint(x: -size.width / 2 + introLabel.frame.width, y: 0)
            introLabel.zPosition = ZPosition.introLabel.rawValue
            addChild(introLabel)
            
            addLevel()
            addLevel()
            
            player.position = levels[1].position // some far off place
            
            let action: SKAction = .sequence([
                .wait(forDuration: 4),
                .run {
                    self.moveToNextLevel(isFirstLevel: true,
                                         duration: Design.levelTransitionDuration * 2)
                }
            ])
            run(action)
        }
        levels[0].addingStartingPositionGoal()
        
        aimAssist.alpha = 0.0
        addChild(aimAssist)
        addChild(player)
        
        createDepthNodes()
        physicsWorld.contactDelegate = self
    }
    
    func setupCamera() {
        cameraNode.zPosition = ZPosition.hud.rawValue
        addChild(cameraNode)
        camera = cameraNode
        
        let inset: CGFloat = 40
        leaderboardButton.position = CGPoint(x: -levelSize.width / 2 + inset,
                                             y: -levelSize.height / 2 + inset)
        cameraNode.addChild(leaderboardButton)
        
        strokesLabel.horizontalAlignmentMode = .left
        strokesLabel.verticalAlignmentMode = .center
        strokesLabel.alpha = 1
        strokesLabel.position = CGPoint(x: leaderboardButton.position.x + Design.leaderboardButtonSize,
                                        y: leaderboardButton.position.y)
        cameraNode.addChild(strokesLabel)
        
        holeLabel.horizontalAlignmentMode = .left
        holeLabel.verticalAlignmentMode = .center
        holeLabel.alpha = 1
        
        cameraNode.addChild(holeLabel)
        
        updateScoreLabel()
        
        if gameStats.holeNumber == 1 {
            strokesLabel.alpha = 0
            holeLabel.alpha = 0
            leaderboardButton.alpha = 0
        }
    }
    
    // MARK: - Level Management -
    
    func updateScoreLabel() {
        strokesLabel.attributedText = NSAttributedString.stylized(string: "\(gameStats.completedHolesStrokes)",
            size: 18, weight: .semibold)
        
        holeLabel.attributedText = NSAttributedString.stylized(string: "+\(gameStats.holeStrokes)",
            size: 15, weight: .semibold)
        
        let xOffset = strokesLabel.position.x + strokesLabel.frame.size.width + 5
        holeLabel.position = CGPoint(x: xOffset,
                                     y: leaderboardButton.position.y)
        
        leaderboardRect = CGRect(x: leaderboardButton.frame.minX,
                                 y: leaderboardButton.frame.minY,
                                 width: holeLabel.frame.maxX - leaderboardButton.frame.minX,
                                 height: leaderboardButton.frame.height).insetBy(dx: -40, dy: -40)
    }
    
    func addLevel() {
        let level = LevelNode(size: levelSize, number: gameStats.holeNumber + levels.count)
        level.goalNode.gravityField.isEnabled = false
        
        if let finalLevel = levels.last {
            let positionX = finalLevel.position.x
                + finalLevel.goalRectLocalSpace.center.x
                - level.startRectLocalSpace.center.x
            let positionY = finalLevel.position.y
                + finalLevel.goalRectLocalSpace.center.y
                - level.startRectLocalSpace.center.y
            level.position = CGPoint(x: positionX, y: positionY)
        } else {
            level.position = CGPoint(x: size.width, y: -level.startRectLocalSpace.center.y)
        }
        
        levels.append(level)
        addChild(level)
        
        var adjusted = [Planet: SKCircleRect]()
        level.localSpacePlanets.forEach { adjusted[$0.key] = $0.value.offset(by: level.position) }
        planetNodesWorldSpace.append(adjusted)
    }
    
    func moveToNextLevel(isFirstLevel: Bool = false,
                         duration: TimeInterval? = Design.levelTransitionDuration) {
        let transitionDuration = duration ?? 0.5
        let transitionTiming = Design.levelTransitionTimingFunction
        
        // Remove the last last level (that was kept in case the user hits backwards)
        let removeAfterTransitionAction: SKAction = .remove(after: transitionDuration)
        
        if isFirstLevel {
            introLabel.run(.remove(after: transitionDuration))
        } else {
            if let lastLevel = lastLevel {
                lastLevel.run(removeAfterTransitionAction)
                planetNodesWorldSpace.removeFirst()
            }
            lastLevel = levels.removeFirst()
            gameStats.completedHole()
            
            workQueue.async {
                self.addLevel()
                SaveUtility.save(scene: self)
                
                let stats = self.gameStats
                if stats.holeNumber > 10 {
                    self.leaderboardUtility.submit(stats: stats)
                }
            }
            if gameStats.holeNumber == 10 {
                #if !os(tvOS)
                SKStoreReviewController.requestReview()
                #endif
            }
        }
        updateScoreLabel()
        
        // Last Goal Animation
        if let newLastLevel = lastLevel {
            let goalNode = newLastLevel.goalNode
            goalNode.gravityField.removeFromParent()
            goalNode.borderNode.removeAllActions()
            
            let nextColor = goalNode.borderNode.color.withAlphaComponent(1)
            let finalColor = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
            let initalColorChangeDuration = transitionDuration * (1 / 4)
            let nextColorChangeDuration = transitionDuration * (3 / 4)
            
            let currentRotation = goalNode.borderNode.zRotation
            let minAmountToRotate = -CGFloat.pi * 5
            let estimatedNewRotation = currentRotation + minAmountToRotate
            
            let rotationRounding = -CGFloat.pi * (1 / 2)
            let rotationPadding = rotationRounding - estimatedNewRotation.truncatingRemainder(dividingBy: rotationRounding)
            let finalRotation = estimatedNewRotation + rotationPadding
            
            let scaleFactor: CGFloat = Design.goalAsStartScale
            
            let lastGoalBorderAction: SKAction = .group([
                .scale(to: scaleFactor, duration: transitionDuration),
                .rotate(toAngle: finalRotation, duration: transitionDuration),
                .sequence([
                    .colorize(with: nextColor, colorBlendFactor: 1, duration: initalColorChangeDuration),
                    .colorize(with: finalColor, colorBlendFactor: 1, duration: nextColorChangeDuration)
                ])
            ])
            lastGoalBorderAction.timingFunction = transitionTiming
            
            let lastGoalInnerAction: SKAction = .group([
                .fadeOut(withDuration: transitionDuration),
                .scale(to: scaleFactor, duration: transitionDuration),
                .rotate(toAngle: -finalRotation, duration: transitionDuration),
                .remove(after: transitionDuration)
            ])
            lastGoalInnerAction.timingFunction = transitionTiming
            
            goalNode.borderNode.run(lastGoalBorderAction)
            goalNode.innerNode.run(lastGoalInnerAction)
            goalNode.label.run(.remove(after: transitionDuration))
        }
        
        // Update the new level variables
        let newActiveLevel = levels[0]
        let newActiveGoal = newActiveLevel.goalNode
        newActiveGoal.gravityField.isEnabled = true
        activeLevelGoalNode = newActiveGoal
        
        let cameraPosition = CGPoint(x: newActiveLevel.position.x + newActiveLevel.frame.size.width / 2,
                                     y: newActiveLevel.position.y + newActiveLevel.frame.size.height / 2)
        activeLevelGoalNodeWorldSpace = newActiveLevel.goalRectLocalSpace.offset(by: newActiveLevel.position)
        
        // Fade in new goal
        let goalAlphaAction: SKAction = .sequence([
            .wait(forDuration: transitionDuration - 0.5),
            .fadeIn(withDuration: 0.75)
        ])
        goalAlphaAction.timingMode = .easeInEaseOut
        newActiveGoal.run(goalAlphaAction)
        
        // Move camera
        if transitionDuration > 0.5 {
            let cameraPositionAction = SKAction.move(to: cameraPosition, duration: transitionDuration)
            cameraPositionAction.timingFunction = transitionTiming
            cameraNode.run(cameraPositionAction)
            
            let cameraOffset = cameraPosition - cameraNode.position
            updateDepthNodes(forCameraPosition: cameraPosition,
                             offset: cameraOffset,
                             duration: transitionDuration)
        } else {
            cameraNode.position = cameraPosition
        }
        
        if Design.colors {
            let backgroundAction: SKAction = .group([
                .colorize(with: .randomBackgroundColor, colorBlendFactor: 1, duration: transitionDuration),
                .move(to: cameraPosition, duration: transitionDuration)
            ])
            backgroundAction.timingFunction = transitionTiming
            backgroundColorNode.run(backgroundAction)
        }
        
        // Player updates
        resetPlayerPosition()
        playerVelocityModifier = 1.0
        
        if gameStats.holeNumber == 2 {
            let fadeAction: SKAction = .sequence([
                .wait(forDuration: transitionDuration),
                .fadeIn(withDuration: transitionDuration / 2)
            ])
            strokesLabel.run(fadeAction)
            holeLabel.run(fadeAction)
            leaderboardButton.run(fadeAction)
            introLabel.run(.remove(after: transitionDuration))
            
            let authAction: SKAction = .sequence([
                .wait(forDuration: transitionDuration),
                .run {
                    self.authenticate()
                }])
            run(authAction)
        } else if gameStats.holeNumber >= 20 && !store.hasUnlockedAllLevels() {
            unlockLevelsNode.alpha = 0
            unlockLevelsNode.updatePrice()
            cameraNode.addChild(unlockLevelsNode)
             let action: SKAction = .sequence([
                           .wait(forDuration: transitionDuration),
                           .fadeIn(withDuration: 0.2)
             ])
            unlockLevelsNode.run(action)
        }
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
        let mag: CGFloat = max(min(magnitude, 200) / 4, 10)
        
        let x = mag * -sin(aimAssist.zRotation)
        let y = mag * cos(aimAssist.zRotation)
        
        player.run(.applyImpulse(CGVector(dx: x, dy: y), duration: 0.5))
        
        let action: SKAction = .sequence([
            .wait(forDuration: 0.2),
            .run {
                physicsBody.fieldBitMask = SpriteCategory.player
            }
        ])
        player.run(action)
        
        gameStats.holeStrokes += 1
        updateScoreLabel()
        
        isPlayerReadyForHit = false
    }
    
    // MARK: - Player -
    
    func resetPlayerPosition(to position: CGPoint? = nil) {
        guard let physicsBody = player.physicsBody, let level = levels.first else {
            fatalError()
        }
        
        contactPlanet = nil
        
        physicsBody.fieldBitMask = SpriteCategory.none
        physicsBody.velocity = CGVector(dx: 0, dy: 0)
        physicsBody.isDynamic = false
        
        if let position = position {
            player.position = position
        } else {
            let startRectWorldSpace = level.startRectLocalSpace.offset(by: level.position)
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
        guard !isPerformingOffscreenReset, let level = levels.first else { return }
        // Camera scale
        
        let safeWidthPadding: CGFloat = levelSize.width / 10
        let levelMinXWorldSpace = level.position.x - levelSize.width / 2 + safeWidthPadding
        let levelMaxXWorldSpace = level.position.x + levelSize.width / 2 - safeWidthPadding
        
        let safeHeightPadding: CGFloat = levelSize.height / 10
        let levelMinYWorldSpace = level.position.y - levelSize.height / 2 + safeHeightPadding
        let levelMaxYWorldSpace = level.position.y + levelSize.height / 2 - safeHeightPadding
        
        var scale: CGFloat = 1.0
        if player.position.x > levelMaxXWorldSpace {
            scale = max(scale, 1.0 + (player.position.x - levelMaxXWorldSpace) / (levelSize.width / 2))
        } else if player.position.x < levelMinXWorldSpace {
            scale = max(scale, 1.0 + (levelMinXWorldSpace - player.position.x) / (levelSize.width / 2))
        }
        
        if player.position.y > levelMaxYWorldSpace {
            scale = max(scale, 1.0 + (player.position.y - levelMaxYWorldSpace) / (levelSize.height / 2))
        } else if player.position.y < levelMinYWorldSpace {
            scale = max(scale, 1.0 + (levelMinYWorldSpace - player.position.y) / (levelSize.height / 2))
        }
        
        let maxScale: CGFloat = 1.6
        cameraNode.run(.scale(to: min(scale, maxScale), duration: 0.25))
        if scale > maxScale && !isOffscreenResetQueued {
            
            isOffscreenResetQueued = true
            let wait: TimeInterval = 1
            let resetAction: SKAction = .sequence([
                .wait(forDuration: wait),
                .run {
                    self.gameStats.fores += 1
                    self.resetPlayerPosition(to: nil)
                    self.isOffscreenResetQueued = false
                }
            ])
            run(resetAction, withKey: "resetAction")
            
            let cameraAction: SKAction = .sequence([
                .wait(forDuration: wait * 0.5),
                .run {
                    self.isPerformingOffscreenReset = true
                },
                .wait(forDuration: wait * 0.5),
                .scale(to: 1, duration: 0.5),
                .run {
                    self.isPerformingOffscreenReset = false
                }
            ])
            cameraAction.timingMode = .easeInEaseOut
            cameraNode.run(cameraAction)
        } else if scale <= maxScale && isOffscreenResetQueued {
            isOffscreenResetQueued = false
            removeAction(forKey: "resetAction")
            cameraNode.removeAllActions()
        }
        
    }
    
    // MARK: - SKScene Overrides -
    
    override func didFinishUpdate() {
        guard let physicsBody = player.physicsBody else {
            fatalError()
        }
        
        if !isPlayerReadyForHit {
            updateCamera()
        }
        
        guard physicsBody.fieldBitMask == SpriteCategory.player else {
            return
        }
        
        let playerVelocity = physicsBody.velocity
        let playerVelocityMagnitude = playerVelocity.magnitude()
        
        // Player path viz
        if playerVelocityMagnitude > 0.01 {
            var newPoint: CGPoint?
            
            let startRectWorldSpace = levels[0].startRectLocalSpace.offset(by: levels[0].position)
            let minStartDistance = startRectWorldSpace.radius * Design.goalAsStartScale + Design.playerPathSpacing
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
            } else if player.position.distance(to: startRectWorldSpace.center) > minStartDistance {
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
                        break
                    }
                }
            }
        }
        
        var newPlayerVelocityModifier: CGFloat = 1
        if let planet = contactPlanet {
            newPlayerVelocityModifier = 0.9
            if playerVelocityMagnitude < 4 {
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
                hapticsUtility.playCompletedHole()
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
    
    override func didMove(to view: SKView) {
        setupScene()
        authenticate()
    }
    
    // MARK: - Other -
    
    func authenticate() {
        guard gameStats.holeNumber > 1 else { return }
        #if !targetEnvironment(simulator)
        guard let presentingController = presentingController else { fatalError() }
        leaderboardUtility.authenticate(authController: { controller in
            presentingController.present(controller, animated: true, completion: nil)
        }, completion: { _ in
            
        })
        #endif
    }
    
    func showLeaderboard() {
        let controller = leaderboardUtility.leaderboardController()
        presentingController?.present(controller, animated: true, completion: nil)
    }
    
    func attemptUnlockPurchase() {
        store.purchaseUnlockLevels()
    }
    
    func attemptRestore() {
        store.restore()
    }
    
    // MARK: - Debug -
    
    func debugMove(x: CGFloat, y: CGFloat) {
        cameraNode.run(.moveBy(x: x, y: y, duration: 0.1))
    }
    
}

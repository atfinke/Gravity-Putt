//
//  GameScene+Init.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 4/4/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

extension GameScene {
    
    // MARK: - Initalization -
    
    class func newGameScene() -> GameScene {
        let scene = GameScene()
        return scene
    }
    
    override func didMove(to view: SKView) {
        setUpScene()
    }
    
    func setUpScene() {
        addChild(player)
        
        backgroundColor = SKColor(white: 0, alpha: 1)
        
        cameraNode.zPosition = ZPosition.hud.rawValue
        addChild(cameraNode)
        camera = cameraNode
        
        statusLabel.alpha = 1
        statusLabel.fontName = "Menlo-Regular"
        statusLabel.fontSize = 22
        statusLabel.position = CGPoint(x: 0, y: size.height / 2 - 30)
        updateScoreLabel()
        cameraNode.addChild(statusLabel)
        
        createDepthNodes()
        
        aimAssist.alpha = 0.0
        addChild(aimAssist)
        
        physicsWorld.contactDelegate = self
        createInitalLevel()
    }
    
    func createInitalLevel() {
        let initalLevel = LevelNode(size: size, number: holeNumber)
        initalLevel.position = CGPoint(x: 0, y: -initalLevel.startRectLocalSpace.center.y)
        
        let goalRectWorldSpaceX = initalLevel.position.x
        let goalRectWorldSpaceY = initalLevel.position.y
        activeLevelGoalNodeWorldSpace = initalLevel.goalRectLocalSpace.offsetBy(dx: goalRectWorldSpaceX,
                                                                                dy: goalRectWorldSpaceY)
        levels.append(initalLevel)
        addChild(initalLevel)
        
        for _ in 0..<2 {
            addLevel()
        }
        moveToNextLevel(isFirstLevel: true)
        
    }
}

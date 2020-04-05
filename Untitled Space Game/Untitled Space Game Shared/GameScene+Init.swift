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
        scene.scaleMode = .resizeFill
        return scene
    }

    override func didMove(to view: SKView) {
        setUpScene()
    }

    func setUpScene() {

//        let aaa = CircleRenderer.create(radius: 50)
//        aaa.cgImage()
//        
//        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
//        let asd = paths.appendingPathComponent("image.png")
//        print(asd)
//        
//        guard let destination = CGImageDestinationCreateWithURL(asd as CFURL, kUTTypePNG, 1, nil) else { fatalError() }
//        CGImageDestinationAddImage(destination, aaa.cgImage(), nil)
//         CGImageDestinationFinalize(destination)

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

        let initalLevel = LevelNode(size: size, number: holeNumber)
        initalLevel.position = CGPoint(x: 0, y: -initalLevel.startRectLocalSpace.center.y)

        let goalRectWorldSpaceX = initalLevel.position.x
        let goalRectWorldSpaceY = initalLevel.position.y
        activeLevelGoalNodeWorldSpace = initalLevel.goalRectLocalSpace.offsetBy(dx: goalRectWorldSpaceX,
                                                                                dy: goalRectWorldSpaceY)
        levels.append(initalLevel)
        addChild(initalLevel)

        createDepthNodes()
        for _ in 0..<2 {
            addLevel()
        }
        moveToNextLevel(isFirstLevel: true)

        aimAssist.alpha = 0.0
        addChild(aimAssist)

        physicsWorld.contactDelegate = self
    }

    func createDepthNodes() {
        let depthLevels = 20

        let maxCount: Int = 150
        let minCount: Int = 40
        let countInterval = CGFloat(maxCount - minCount) / CGFloat(depthLevels)

        let maxRadius: CGFloat = 1
        let minRadius: CGFloat = 0.5
        let radiusInterval = CGFloat(maxRadius - minRadius) / CGFloat(depthLevels)

        for starDepthLevel in (0..<depthLevels).reversed() {
            let maxCount = maxCount - Int(countInterval) * (depthLevels - starDepthLevel)

            let minDepthRadius = (minRadius - 0.2) + radiusInterval * CGFloat(starDepthLevel)
            let maxDepthRadius = minRadius + radiusInterval * CGFloat(starDepthLevel)

            let starDepthNode = StarDepthNode(size: CGSize(width: size.width * 2, height: size.height * 3),
                                              countRange: 0..<maxCount,
                                              radiusRange: minDepthRadius..<maxDepthRadius)
            starDepthLevelNodes.append([starDepthNode])

            addChild(starDepthNode)
        }
    }
}

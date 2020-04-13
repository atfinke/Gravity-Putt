//
//  GameScene+Depth.swift
//  Gravity Golf
//
//  Created by Andrew Finke on 4/6/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

extension GameScene {

    func createDepthNodes() {
        guard var levelPosition = levels.first?.position else { fatalError() }
        if gameStats.holeNumber == 1 {
            levelPosition = introLabel.position
        }
        
        let depthLevels = 15

        let maxCount: Int = 350
        let minCount: Int = 180
        let countInterval = CGFloat(maxCount - minCount) / CGFloat(depthLevels)

        let maxRadius: CGFloat = 1
        let minRadius: CGFloat = 0.4
        let radiusInterval = CGFloat(maxRadius - minRadius) / CGFloat(depthLevels)

        for starDepthLevel in (0..<depthLevels).reversed() {
            let maxCount = maxCount - Int(countInterval) * (depthLevels - starDepthLevel)

            let minDepthRadius = (minRadius - 0.2) + radiusInterval * CGFloat(starDepthLevel)
            let maxDepthRadius = minRadius + radiusInterval * CGFloat(starDepthLevel)

            let starDepthNode = StarDepthNode(size: CGSize(width: size.width * 2,
                                                           height: size.height * 2),
                                              countRange: 0..<maxCount,
                                              radiusRange: minDepthRadius..<maxDepthRadius)
            starDepthNode.position = CGPoint(x: levelPosition.x,
                                             y: levelPosition.y)
            starDepthNodes.append([starDepthNode])

            addChild(starDepthNode)
        }
    }

    func updateDepthNodes(forCameraPosition cameraPosition: CGPoint,
                          offset cameraOffset: CGPoint,
                          duration: TimeInterval) {
        var starDepthsToAdd = [Int: StarDepthNode]()
        var starDepthsToRemove = [Int: StarDepthNode]()

        for (depthLevel, depthNodesAtLevel) in starDepthNodes.enumerated() {
            let scale = 0.75 * CGFloat(depthLevel + 1) / CGFloat(starDepthNodes.count)
            let offset = cameraOffset.scaleComponents(by: scale)

            for (depthLevelNodeIndex, depthLevelNode) in depthNodesAtLevel.enumerated() {
                let newPosition = depthLevelNode.position + offset

                let parallaxAction = SKAction.move(to: newPosition, duration: duration)
                parallaxAction.timingFunction = Design.levelTransitionTimingFunction
                depthLevelNode.run(parallaxAction)

                let cameraPaddedDistanceFromDepthNode = (cameraPosition.x + size.width * 2) - (newPosition.x + depthLevelNode.frame.width)

                if cameraPaddedDistanceFromDepthNode > 0 && depthLevelNodeIndex == depthNodesAtLevel.count - 1 {
                    let starDepthNode = StarDepthNode(previousNode: depthLevelNode)
                    starDepthNode.position = CGPoint(x: newPosition.x + depthLevelNode.frame.width,
                                                     y: cameraPosition.y)
                    addChild(starDepthNode)
                    starDepthsToAdd[depthLevel] = starDepthNode
                } else if cameraPaddedDistanceFromDepthNode > size.width * 2 && depthLevelNodeIndex == 0 {
                    starDepthsToRemove[depthLevel] = depthLevelNode
                }
            }
        }

        for (key, value) in starDepthsToAdd {
            starDepthNodes[key].append(value)
        }
        for (key, value) in starDepthsToRemove {
            starDepthNodes[key].removeFirst()
            value.run(.remove(after: duration))
        }

    }

}

//
//  LevelGenerator.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class Level: SKNode {
    
    // MARK: - Properties -
    
    let goalNode: Goal
    let goalSafeRect: CGRect
    let startRect: CGRect
    
    // MARK: - Initalization -
    
    init(size: CGSize, startSize: CGSize) {
        
        var children = [SKNode]()
        
        let startPositionYBounds = size.height * 0.25
        startRect = CGRect(x: -size.width / 2 + 30,
                           y: CGFloat.random(in: -(startPositionYBounds + startSize.height)...startPositionYBounds),
                           width: startSize.width,
                           height: startSize.height)
        
        let start = SKShapeNode(rect: startRect)
        start.fillColor = SKColor.yellow.withAlphaComponent(0.2)
//        addChild(back)
        
        let goalRadius = 0.1 * size.height
        let goalWidthPercent = goalRadius / size.width
        let goalWidthMaxBounds = 0.5 - goalWidthPercent
        let goalHeightBounds = 0.5 - (goalRadius * 2) / size.height
        let goalPositionX = CGFloat.random(in: goalWidthPercent...goalWidthMaxBounds) * size.width
        let goalPositionY = CGFloat.random(in: -(goalHeightBounds)...goalHeightBounds) * size.height
        let goalPosition = CGPoint(x: goalPositionX, y: goalPositionY)
        let goalSafeRect = CGRect(origin: goalPosition,
                              size: CGSize(width: goalRadius * 2.1,
                                           height: goalRadius * 2.1))
        self.goalSafeRect = goalSafeRect
        
        goalNode = Goal(radius: goalRadius, color: .yellow)
        goalNode.position = goalPosition
        children.append(goalNode)
        
        var planetRects = [CGRect]()
        let planetInsertionAttemptCount = Int.random(in: 2...5)
        for _ in 0..<planetInsertionAttemptCount {
            let planetRadius = CGFloat.random(in: 0.05...0.15) * size.height
            let planetPosition = CGPoint(x: 0 + CGFloat.random(in: -0.5..<0.5) * size.width,
                                         y: 0 + CGFloat.random(in: -0.5..<0.5) * size.height)
            let planetSafeRect = CGRect(origin: planetPosition,
                                        size: CGSize(width: planetRadius * 2.1,
                                                     height: planetRadius * 2.1))
            
            if planetSafeRect.intersects(startRect.insetBy(dx: -20, dy: -20)) || planetSafeRect.intersects(goalSafeRect) {
                continue
            } else if !planetRects.filter({ $0.intersects(planetSafeRect) }).isEmpty {
                continue
            }
            planetRects.append(planetSafeRect)
            
            let planet = Planet(radius: planetRadius, color: .blue)
            planet.position = planetPosition
            children.append(planet)
        }
        
        super.init()
        
                for _ in 0..<50 {
                    let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.15..<0.75))
                    star.fillColor = SKColor(white: CGFloat.random(in: 0.5...1), alpha: 0.8)
                    star.position = CGPoint(x: CGFloat.random(in: -size.width / 2...size.width / 2), y: CGFloat.random(in: -size.height / 2...size.height / 2))
                    addChild(star)
                }
        
        children.forEach { addChild($0) }
        
//        let back = SKShapeNode(rect: CGRect(origin: CGPoint(x: -size.width / 2, y: -size.height / 2), size: size))
//        back.fillColor = SKColor.blue.withAlphaComponent(0.2)
//        addChild(back)
//        addChild(start)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

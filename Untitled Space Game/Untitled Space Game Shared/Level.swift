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
    
    private let size: CGSize
    
    let goalNode: Goal
    let goalRectLocalSpace: CGRect
    
    let startRectLocalSpace: CGRect
    var planetRectsLocalSpace = [CGRect]()
    
    // MARK: - Initalization -
    
    init(size: CGSize, startSize: CGSize) {
        self.size = size
        
        var children = [SKNode]()
        
        let startPositionYBounds = size.height * 0.25
        startRectLocalSpace = CGRect(x: -size.width / 2 + 30,
                                     y: CGFloat.random(in: -(startPositionYBounds + startSize.height)...startPositionYBounds),
                                     width: startSize.width,
                                     height: startSize.height)
        
        let goalRadius = 0.1 * size.height
        let goalWidthPercent = goalRadius / size.width
        let goalWidthMaxBounds = 0.5 - goalWidthPercent
        let goalHeightBounds = 0.5 - (goalRadius * 2) / size.height
        let goalPositionX = CGFloat.random(in: goalWidthPercent...goalWidthMaxBounds) * size.width
        let goalPositionY = CGFloat.random(in: -(goalHeightBounds)...goalHeightBounds) * size.height
        let goalPosition = CGPoint(x: goalPositionX,
                                   y: goalPositionY)
        goalRectLocalSpace = CGRect(origin: goalPosition,
                                        size: CGSize(width: goalRadius * 2,
                                                     height: goalRadius * 2))
        
        goalNode = Goal(radius: goalRadius, color: .yellow)
        goalNode.position = goalPosition
        children.append(goalNode)
        super.init()

//        for _ in 0..<250 {
//            let star = SKShapeNode(circleOfRadius: CGFloat.random(in: 0.15..<0.75))
//            star.zPosition = 1
//            star.fillColor = SKColor(white: CGFloat.random(in: 0.5...1), alpha: 0.8)
//            star.position = CGPoint(x: CGFloat.random(in: -size.width...size.width),
//                                    y: CGFloat.random(in: -size.height...size.height))
//            addChild(star)
//        }
        
        children.forEach { addChild($0) }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -

    func createPlanets(avoiding localSpacePlanets: [CGRect]) {
//        for rect in localSpacePlanets {
//            let start = SKShapeNode(rect: rect)
//            start.fillColor = SKColor.yellow.withAlphaComponent(0.6)
//            addChild(start)
//        }
        
        let planetInsertionAttemptCount = Int.random(in: 5...10)
        for _ in 2..<planetInsertionAttemptCount {
            let planetRadius = CGFloat.random(in: 0.075...0.2) * size.height
            let planetPosition = CGPoint(x: 0 + CGFloat.random(in: -0.5..<0.5) * size.width,
                                         y: 0 + CGFloat.random(in: -0.5..<0.5) * size.height)
            let planetRect = CGRect(origin: planetPosition,
                                        size: CGSize(width: planetRadius * 2,
                                                     height: planetRadius * 2))
                .insetBy(dx: -planetRadius/3, dy: -planetRadius/3)


            if planetRect.intersects(startRectLocalSpace.offsetBy(dx: startRectLocalSpace.width / 2,
                                                                  dy: startRectLocalSpace.height / 2)) || planetRect.intersects(goalRectLocalSpace.insetBy(dx: -goalRectLocalSpace.width, dy: -goalRectLocalSpace.height)) {
                continue
            } else if !planetRectsLocalSpace.filter({ $0.intersects(planetRect) }).isEmpty {
                continue
            } else if !localSpacePlanets.filter({ $0.intersects(planetRect) }).isEmpty {
                continue
            }
            planetRectsLocalSpace.append(planetRect)
            
            let planet = Planet(radius: planetRadius, color: .blue)
            planet.zPosition = 0
            planet.position = planetPosition
            addChild(planet)
        }
    }
    
}

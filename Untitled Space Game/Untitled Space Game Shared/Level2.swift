//
//  Level2.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/31/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

struct Debugging {
    static let isLevelVizOn: Bool = false
}

struct Design {
    static let goalRadius: CGFloat = 40.0
}

class Level2: SKNode {
    
    // MARK: - Properties -
    
    private let size: CGSize

    let goalNode: Goal
    let goalRectLocalSpace: SKCircleRect

    let startRectLocalSpace: SKCircleRect
    
    // MARK: - Initalization -
    
    init(size: CGSize, number: Int) {
        self.size = size

        let goalRadius: CGFloat = Design.goalRadius
        
        let originX = -size.width / 2
        let originY = -size.height / 2
        
        let startPositionBoundaryLeftPadding: CGFloat = 20
        let startPositionBoundaryTopPadding: CGFloat = 50
        let startPositionBoundaryBottomPadding: CGFloat = 50
        let goalPositionBoundaryRightPadding: CGFloat = 40
        let goalPositionBoundaryTopPadding: CGFloat = 40
        let goalPositionBoundaryBottomPadding: CGFloat = 150
        
        let startMinBoundsPositionX = originX + startPositionBoundaryLeftPadding
        let startMaxBoundsPositionX = originX + (size.width / 4)
        let startBoundsPositionWidth = startMaxBoundsPositionX - startMinBoundsPositionX
        let startMinCenterPositionX = startMinBoundsPositionX + goalRadius
        let startMaxCenterPositionX = startMaxBoundsPositionX - goalRadius
        
        let startMinBoundsPositionY = originY + startPositionBoundaryBottomPadding
        let startMaxBoundsPositionY = size.height / 2 - startPositionBoundaryTopPadding
        let startBoundsPositionHeight = startMaxBoundsPositionY - startMinBoundsPositionY
        let startMinCenterPositionY = startMinBoundsPositionY + goalRadius
        let startMaxCenterPositionY = startMaxBoundsPositionY - goalRadius
        
        let startPositionBoundaryRect = CGRect(x: startMinBoundsPositionX,
                                               y: startMinBoundsPositionY,
                                               width: startBoundsPositionWidth,
                                               height: startBoundsPositionHeight)
        
        let goalMinBoundsPositionX = size.width * (1 / 2) * (1 / 3)
        let goalMaxBoundsPositionX = size.width / 2 - goalPositionBoundaryRightPadding
        let goalBoundsPositionWidth = goalMaxBoundsPositionX - goalMinBoundsPositionX
        let goalMinCenterPositionX = goalMinBoundsPositionX + goalRadius
        let goalMaxCenterPositionX = goalMaxBoundsPositionX - goalRadius
        
        let goalMinBoundsPositionY = originY + goalPositionBoundaryBottomPadding
        let goalMaxBoundsPositionY = size.height / 2 - goalPositionBoundaryTopPadding
        let goalBoundsPositionHeight = goalMaxBoundsPositionY - goalMinBoundsPositionY
        let goalMinCenterPositionY = goalMinBoundsPositionY + goalRadius
        let goalMaxCenterPositionY = goalMaxBoundsPositionY - goalRadius
        
        let goalPositionBoundaryRect = CGRect(x: goalMinBoundsPositionX,
                                              y: goalMinBoundsPositionY,
                                              width: goalBoundsPositionWidth,
                                              height: goalBoundsPositionHeight)
        
        let startPositionX = CGFloat.random(in: startMinCenterPositionX...startMaxCenterPositionX)
        let startPositionY = CGFloat.random(in: startMinCenterPositionY...startMaxCenterPositionY)
        startRectLocalSpace = SKCircleRect(centerX: startPositionX,
                                     centerY: startPositionY,
                                     radius: goalRadius)
        
        
        let goalPositionX = CGFloat.random(in: goalMinCenterPositionX...goalMaxCenterPositionX)
        let goalPositionY = CGFloat.random(in: goalMinCenterPositionY...goalMaxCenterPositionY)
        let goalPosition = CGPoint(x: goalPositionX, y: goalPositionY)
        goalNode = Goal(radius: goalRadius, levelNumber: number)
        goalNode.position = goalPosition
        goalRectLocalSpace = SKCircleRect(centerX: goalPosition.x,
                                    centerY: goalPosition.y,
                                    radius: goalRadius)
        
        let planetMinBoundsPositionX = startMaxBoundsPositionX
        let planetMaxBoundsPositionX = goalMinBoundsPositionX
        
        let planetPositionBoundaryRect = CGRect(x: planetMinBoundsPositionX,
        y: -size.height / 2,
        width: goalMinBoundsPositionX - startMaxBoundsPositionX,
        height: size.height)
        
        super.init()
        
        
        

        
        let startSafeAreaWidthInset = -startRectLocalSpace.radius * 3 / 4
        let startSafeArea = startRectLocalSpace.insetBy(d: startSafeAreaWidthInset)
        
        let goalSafeAreaWidthInset = -goalRectLocalSpace.radius * 3 / 4
        let goalSafeArea = goalRectLocalSpace.insetBy(d: goalSafeAreaWidthInset)
        
        vizSize(size: size)
        viz(startBoundary: startPositionBoundaryRect,
            goalBoundary: goalPositionBoundaryRect,
            planetBoundary: planetPositionBoundaryRect)
        vizPossibleGoalPositions(xRange: goalMinCenterPositionX...goalMaxCenterPositionX,
                                 yRange: goalMinCenterPositionY...goalMaxCenterPositionY,
                                 radius: goalRadius)
        viz(startSafeArea: startSafeArea.cgRect, goalSafeArea: goalSafeArea.cgRect)
        
        
        addChild(goalNode)
        
        let localSpacePlanets = [SKCircleRect]()
        let minPlanetRadius = size.width / 25
        
        let planetInsertionAttemptCount = Int.random(in: 4...6)
        for _ in 2..<planetInsertionAttemptCount {
            
            let planetSafeAreaRadiusPaddingMultiplier: CGFloat = 1.75
            let maxPlanetSafeAreaRadius = (planetMaxBoundsPositionX - planetMinBoundsPositionX) / 2
            let maxPlanetRadius: CGFloat = maxPlanetSafeAreaRadius / planetSafeAreaRadiusPaddingMultiplier
            
            let planetRadius = CGFloat.random(in: minPlanetRadius...maxPlanetRadius)
            let planetRadiusSafeArea = planetRadius * planetSafeAreaRadiusPaddingMultiplier
            
            let planetMinCenterPositionX = planetMinBoundsPositionX + planetRadiusSafeArea
            let planetMaxCenterPositionX = planetMaxBoundsPositionX - planetRadiusSafeArea
            
            let planetPositionX = CGFloat.random(in: planetMinCenterPositionX...planetMaxCenterPositionX)
            let planetPositionY = CGFloat.random(in: startMinCenterPositionY...startMaxCenterPositionY)
            let planetPosition = CGPoint(x: planetPositionX, y: planetPositionY)
            
            let planetSafeRect = SKCircleRect(centerX: planetPositionX,
                                        centerY: planetPositionY,
                                        radius: planetRadiusSafeArea)
            
            if planetSafeRect.innerCircleIntersects(circleRect: startSafeArea) || planetSafeRect.innerCircleIntersects(circleRect: goalSafeArea) {
                continue
            } else if !planetRectsLocalSpace.filter({ $0.innerCircleIntersects(circleRect: planetSafeRect) }).isEmpty {
                continue
            } else if !localSpacePlanets.filter({ $0.innerCircleIntersects(circleRect: planetSafeRect) }).isEmpty {
                continue
            }
            planetRectsLocalSpace.append(planetSafeRect)
            viz(planetSafeRect: planetSafeRect.cgRect)
            
            let planet = Planet(radius: planetRadius, color: .blue)
            planet.zPosition = ZPosition.planet.rawValue
            planet.position = planetPosition
            addChild(planet)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Helpers -
    
    
    
    func createPlanets(avoiding localSpacePlanets: [CGRect]) {
        
    }
    
    private func vizSize(size: CGSize) {
        if !Debugging.isLevelVizOn {
            return
        }
        let viz = SKShapeNode(rectOf: size)
        viz.fillColor = SKColor.blue.withAlphaComponent(0.15)
        addChild(viz)
    }
    
    private func viz(startBoundary: CGRect, goalBoundary: CGRect, planetBoundary: CGRect) {
                let startPositionBoundaryNode = SKShapeNode(rect: startBoundary)
                startPositionBoundaryNode.fillColor = .blue
                addChild(startPositionBoundaryNode)
        
                let goalPositionBoundaryNode = SKShapeNode(rect: goalBoundary)
                goalPositionBoundaryNode.fillColor = .darkGray
                addChild(goalPositionBoundaryNode)
        
        let planetPositionBoundaryNode = SKShapeNode(rect: planetBoundary)
                planetPositionBoundaryNode.fillColor = .green
                addChild(planetPositionBoundaryNode)
    }
    
    private func viz(planetSafeRect: CGRect) {
        if !Debugging.isLevelVizOn {
            return
        }
        let viz = SKShapeNode(rect: planetSafeRect, cornerRadius: planetSafeRect.width / 2)
        viz.fillColor = SKColor.white.withAlphaComponent(0.1)
        addChild(viz)
    }
    
    private func viz(startSafeArea: CGRect, goalSafeArea: CGRect) {
        if !Debugging.isLevelVizOn {
            return
        }
        let startViz = SKShapeNode(rect: startSafeArea, cornerRadius: startSafeArea.width / 2)
        startViz.fillColor = SKColor.white.withAlphaComponent(1)
        addChild(startViz)
        
        let goalViz = SKShapeNode(rect: goalSafeArea, cornerRadius: goalSafeArea.width / 2)
        goalViz.fillColor = SKColor.yellow.withAlphaComponent(0.5)
        addChild(goalViz)
    }
  
    private func vizPossibleGoalPositions(xRange: ClosedRange<CGFloat>,
                                          yRange: ClosedRange<CGFloat>,
                                          radius: CGFloat) {
        if !Debugging.isLevelVizOn {
            return
        }
        for _ in 0...40 {
            let goalPositionX = CGFloat.random(in: xRange)
            let goalPositionY = CGFloat.random(in: yRange)
            
            let goal = Goal(radius: radius, levelNumber: 0)
            goal.position = CGPoint(x: goalPositionX, y: goalPositionY)
            addChild(goal)
        }
    }
    
}

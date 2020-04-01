//
//  LevelGenerator.swift
//  Untitled Space Game
//
//  Created by Andrew Finke on 3/16/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

private let isVizOn = false

class Level: SKNode {

    // MARK: - Properties -

    private let size: CGSize

    let goalNode: Goal
    let goalRectLocalSpace: CGRect

    let startRectLocalSpace: CGRect
    var planetRectsLocalSpace = [CGRect]()

    // MARK: - Initalization -

    init(size: CGSize, startSize: CGSize, num: Int) {
        self.size = size

        var children = [SKNode]()

        let startPositionX = -size.width * CGFloat(3.0 / 8.0)
        let startPositionYBounds = size.height * 0.25
        let startPositionY = CGFloat.random(in: -(startPositionYBounds + startSize.height)...startPositionYBounds)

        startRectLocalSpace = CGRect(x: startPositionX,
                                     y: startPositionY,
                                     width: startSize.width,
                                     height: startSize.height)

        let goalRadius: CGFloat = 50
        let goalPositionXVariable = CGFloat.random(in: -2...0.5) * CGFloat(1.0 / 16.0)
        let goalPositionX = size.width * CGFloat(3.0 / 8.0) + size.width * goalPositionXVariable

        let goalHeightBounds = 0.5 - (goalRadius * 2) / size.height
        let goalPositionY = CGFloat.random(in: -(goalHeightBounds)...goalHeightBounds) * size.height
        let goalPosition = CGPoint(x: goalPositionX, y: goalPositionY)

        let goalSize = CGSize(width: goalRadius * 2, height: goalRadius * 2)
        goalRectLocalSpace = CGRect(origin: goalPosition, size: goalSize)

        goalNode = Goal(radius: goalRadius, levelNumber: num)
        goalNode.position = goalRectLocalSpace.center
        children.append(goalNode)
        super.init()

        if isVizOn {
            let _viz_level = SKShapeNode(rectOf: size)
            _viz_level.fillColor = SKColor.blue.withAlphaComponent(0.15)
            addChild(_viz_level)

            let _viz_start = SKShapeNode(rect: startRectLocalSpace,
                                         cornerRadius: startRectLocalSpace.width / 2)
            _viz_start.fillColor = SKColor.yellow.withAlphaComponent(0.4)
            addChild(_viz_start)
        }

        children.forEach { addChild($0) }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers -

    func createPlanets(avoiding localSpacePlanets: [CGRect]) {
        let startSafeAreaWidthInset = -startRectLocalSpace.width * 3 / 4
        let startSafeAreaHeightInset = -startRectLocalSpace.height * 3 / 4
        let startSafeArea = startRectLocalSpace.insetBy(dx: startSafeAreaWidthInset,
                                                        dy: startSafeAreaHeightInset)

        let goalSafeAreaWidthInset = -goalRectLocalSpace.width * 3 / 4
        let goalSafeAreaHeightInset = -goalRectLocalSpace.height * 3 / 4
        let goalSafeArea = goalRectLocalSpace.insetBy(dx: goalSafeAreaWidthInset,
                                                      dy: goalSafeAreaHeightInset)

        if isVizOn {
            let _viz_start_safe = SKShapeNode(rect: startSafeArea,
                                              cornerRadius: startSafeArea.width / 2)
            _viz_start_safe.fillColor = SKColor.white.withAlphaComponent(1)
            addChild(_viz_start_safe)

            //            let _viz_goal_safe = SKShapeNode(rect: goalSafeArea,
            //                                             cornerRadius: goalSafeArea.width / 2)
            //            _viz_goal_safe.fillColor = SKColor.yellow.withAlphaComponent(0.5)
            //            addChild(_viz_goal_safe)

            for rect in localSpacePlanets {
                let _viz_planet = SKShapeNode(rect: rect, cornerRadius: rect.width / 2)
                _viz_planet.fillColor = SKColor.red.withAlphaComponent(0.5)
                addChild(_viz_planet)
            }
        }

        let planetInsertionAttemptCount = Int.random(in: 4...10)
        for _ in 2..<planetInsertionAttemptCount {
            let planetRadius = CGFloat.random(in: 0.15...0.3) * size.height
            let planetRadiusWidthPercent = planetRadius / size.width
            let planetRadiusHeightPercent = planetRadius / size.height

            let planetPosition = CGPoint(x: CGFloat.random(in: -0.5..<(0.5 - planetRadiusWidthPercent)) * size.width,
                                         y: CGFloat.random(in: -0.5..<(0.5 - planetRadiusHeightPercent)) * size.height)

            let planetSafeAreaPadding = planetRadius * CGFloat(3.0 / 4.0)
            let planetSize = CGSize(width: planetRadius * 2, height: planetRadius * 2)

            let planetSafeRect = CGRect(origin: planetPosition, size: planetSize)
                .insetBy(dx: -planetSafeAreaPadding, dy: -planetSafeAreaPadding)

            if planetSafeRect.innerCircleIntersects(circleRect: startSafeArea) || planetSafeRect.innerCircleIntersects(circleRect: goalSafeArea) {
                continue
            } else if !planetRectsLocalSpace.filter({ $0.innerCircleIntersects(circleRect: planetSafeRect) }).isEmpty {
                continue
            } else if !localSpacePlanets.filter({ $0.innerCircleIntersects(circleRect: planetSafeRect) }).isEmpty {
                continue
            }
            planetRectsLocalSpace.append(planetSafeRect)

            if isVizOn {
                let _viz_planet = SKShapeNode(rect: planetSafeRect,
                                              cornerRadius: planetSafeRect.width / 2)
                _viz_planet.fillColor = SKColor.white.withAlphaComponent(0.1)
                addChild(_viz_planet)
            }

            let planet = Planet(radius: planetRadius, color: .blue)
            planet.zPosition = ZPosition.planet.rawValue
            planet.position = planetSafeRect.center
            addChild(planet)
        }
    }

}

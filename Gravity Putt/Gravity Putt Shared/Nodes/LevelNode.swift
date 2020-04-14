//
//  LevelNode.swift
//  Gravity Putt
//
//  Created by Andrew Finke on 3/31/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import SpriteKit

class LevelNode: SKNode, Codable {

    // MARK: - Properties -

    let number: Int
    let goalNode: Goal
    let goalRectLocalSpace: SKCircleRect
    let startRectLocalSpace: SKCircleRect
    var localSpacePlanets = [Planet: SKCircleRect]()

    // MARK: - Initalization -

    init(size: CGSize, number: Int) {
        self.number = number

        let goalRadius: CGFloat = Design.goalRadius

        let originX = -size.width / 2
        let originY = -size.height / 2

        let startPositionBoundaryLeftPadding: CGFloat = 50
        let startPositionBoundaryTopPadding: CGFloat = 20
        let startPositionBoundaryBottomPadding: CGFloat = 20
        let goalPositionBoundaryRightPadding: CGFloat = 50
        let goalPositionBoundaryTopPadding: CGFloat = 20
        let goalPositionBoundaryBottomPadding: CGFloat = 20

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
        var startPositionY = CGFloat.random(in: startMinCenterPositionY...startMaxCenterPositionY)
        if number == 1 {
            startPositionY = 0
        }
        startRectLocalSpace = SKCircleRect(centerX: startPositionX,
                                           centerY: startPositionY,
                                           radius: goalRadius)

        let goalPositionX = CGFloat.random(in: goalMinCenterPositionX...goalMaxCenterPositionX)
        var goalPositionY = CGFloat.random(in: goalMinCenterPositionY...goalMaxCenterPositionY)
        if number == 1 {
            goalPositionY = 0
        }
        let goalPosition = CGPoint(x: goalPositionX, y: goalPositionY)
        goalNode = Goal(levelNumber: number)
        goalNode.alpha = 0
        goalNode.position = goalPosition
        goalRectLocalSpace = SKCircleRect(centerX: goalPosition.x,
                                          centerY: goalPosition.y,
                                          radius: goalRadius)

        let planetBoundsPadding: CGFloat = 20
        let planetMinBoundsPositionX = startMaxBoundsPositionX + planetBoundsPadding
        let planetMaxBoundsPositionX = goalMinBoundsPositionX - planetBoundsPadding
        let planetBoundsPositionWidth = planetMaxBoundsPositionX - planetMinBoundsPositionX

        let planetMinBoundsPositionY = goalMinBoundsPositionY
        let planetMaxBoundsPositionY = goalMaxBoundsPositionY
        let planetBoundsPositionHeight = planetMaxBoundsPositionY - planetMinBoundsPositionY

        let planetPositionBoundaryRect = CGRect(x: planetMinBoundsPositionX,
                                                y: planetMinBoundsPositionY,
                                                width: planetBoundsPositionWidth,
                                                height: planetBoundsPositionHeight)

        let verticalPlanetBoundarySize: CGFloat = 300
        let upperPlanetMinBoundsPositionX = startMinBoundsPositionX
        let upperPlanetMaxBoundsPositionX = goalMinBoundsPositionX
        let upperPlanetMinBoundsPositionY = goalMaxBoundsPositionY
        let upperPlanetMaxBoundsPositionY = upperPlanetMinBoundsPositionY + verticalPlanetBoundarySize
        let upperPlanetBoundsPositionWidth = upperPlanetMaxBoundsPositionX - upperPlanetMinBoundsPositionX
        let upperPlanetBoundsPositionHeight = upperPlanetMaxBoundsPositionY - upperPlanetMinBoundsPositionY

        let upperPlanetPositionBoundaryRect = CGRect(x: upperPlanetMinBoundsPositionX,
                                                     y: upperPlanetMinBoundsPositionY,
                                                     width: upperPlanetBoundsPositionWidth,
                                                     height: upperPlanetBoundsPositionHeight)

        let lowerPlanetMinBoundsPositionX = startMinBoundsPositionX
        let lowerPlanetMaxBoundsPositionX = goalMinBoundsPositionX
        let lowerPlanetMinBoundsPositionY = goalMinBoundsPositionY - verticalPlanetBoundarySize
        let lowerPlanetMaxBoundsPositionY = goalMinBoundsPositionY
        let lowerPlanetBoundsPositionWidth = lowerPlanetMaxBoundsPositionX - lowerPlanetMinBoundsPositionX
        let lowerPlanetBoundsPositionHeight = lowerPlanetMaxBoundsPositionY - lowerPlanetMinBoundsPositionY

        let lowerPlanetPositionBoundaryRect = CGRect(x: lowerPlanetMinBoundsPositionX,
                                                     y: lowerPlanetMinBoundsPositionY,
                                                     width: lowerPlanetBoundsPositionWidth,
                                                     height: lowerPlanetBoundsPositionHeight)

        super.init()

        name = number.description

        let startSafeAreaWidthInset = -startRectLocalSpace.radius * 3 / 4
        let startSafeArea = startRectLocalSpace.insetBy(d: startSafeAreaWidthInset)

        let goalSafeAreaWidthInset = -goalRectLocalSpace.radius * 3 / 4
        let goalSafeArea = goalRectLocalSpace.insetBy(d: goalSafeAreaWidthInset)

        vizSize(size: size)
        viz(startBoundary: startPositionBoundaryRect,
            goalBoundary: goalPositionBoundaryRect,
            planetBoundary: planetPositionBoundaryRect,
            upperPlanetBoundary: upperPlanetPositionBoundaryRect,
            lowerPlanetBoundary: lowerPlanetPositionBoundaryRect)

        vizPossibleGoalPositions(xRange: goalMinCenterPositionX...goalMaxCenterPositionX,
                                 yRange: goalMinCenterPositionY...goalMaxCenterPositionY,
                                 radius: goalRadius)
        viz(startSafeArea: startSafeArea.cgRect, goalSafeArea: goalSafeArea.cgRect)

        addChild(goalNode)
        
        if number == 1 {
            return
        }

        var localSpaceSafeAreaPlanetRects = [SKCircleRect]()
        let minPlanetRadius = size.width / 25

        let planetInsertionAttemptCount = Int.random(in: 4...6)
        for _ in 2..<planetInsertionAttemptCount {
            let maxPlanetSafeAreaRadius = min(planetBoundsPositionWidth, planetBoundsPositionHeight) / 2
            guard let result = attemptPlanetCreation(maxSafeAreaRadius: maxPlanetSafeAreaRadius,
                                                     minPlanetRadius: minPlanetRadius,
                                                     minBoundsX: planetMinBoundsPositionX,
                                                     maxBoundsX: planetMaxBoundsPositionX,
                                                     minBoundsY: planetMinBoundsPositionY,
                                                     maxBoundsY: planetMaxBoundsPositionY,
                                                     startSafeArea: startSafeArea,
                                                     goalSafeArea: goalSafeArea,
                                                     localSpacePlanets: localSpaceSafeAreaPlanetRects) else { continue }

            localSpacePlanets[result.planet] = result.rect
            localSpaceSafeAreaPlanetRects.append(result.safe)
        }

        for _ in 0..<1 {
            let maxPlanetSafeAreaRadius = min(upperPlanetBoundsPositionWidth, verticalPlanetBoundarySize) / 3
            let useTop = Bool.random()
            if useTop {
                let maxPlanetSafeAreaRadius = verticalPlanetBoundarySize / 2
                guard let result = attemptPlanetCreation(maxSafeAreaRadius: maxPlanetSafeAreaRadius,
                                                         minPlanetRadius: minPlanetRadius,
                                                         minBoundsX: upperPlanetMinBoundsPositionX,
                                                         maxBoundsX: upperPlanetMaxBoundsPositionX,
                                                         minBoundsY: upperPlanetMinBoundsPositionY,
                                                         maxBoundsY: upperPlanetMaxBoundsPositionY,
                                                         startSafeArea: startSafeArea,
                                                         goalSafeArea: goalSafeArea,
                                                         localSpacePlanets: localSpaceSafeAreaPlanetRects) else { break }

                localSpacePlanets[result.planet] = result.rect
                localSpaceSafeAreaPlanetRects.append(result.safe)
            } else {
                guard let result = attemptPlanetCreation(maxSafeAreaRadius: maxPlanetSafeAreaRadius,
                                                         minPlanetRadius: minPlanetRadius,
                                                         minBoundsX: lowerPlanetMinBoundsPositionX,
                                                         maxBoundsX: lowerPlanetMaxBoundsPositionX,
                                                         minBoundsY: lowerPlanetMinBoundsPositionY,
                                                         maxBoundsY: lowerPlanetMaxBoundsPositionY,
                                                         startSafeArea: startSafeArea,
                                                         goalSafeArea: goalSafeArea,
                                                         localSpacePlanets: localSpaceSafeAreaPlanetRects) else { break }

                localSpacePlanets[result.planet] = result.rect
                localSpaceSafeAreaPlanetRects.append(result.safe)
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Helpers -

    func addingStartingPositionGoal() {
        let initalGoal = Goal(levelNumber: 0)
        initalGoal.gravityField.removeFromParent()
        initalGoal.borderNode.color = SKColor(red: 1, green: 1, blue: 1, alpha: 1)
        initalGoal.innerNode.removeFromParent()
        initalGoal.label.removeFromParent()
        initalGoal.borderNode.removeAllActions()
        initalGoal.zRotation = -CGFloat.pi * (1 / 2)
        initalGoal.xScale = 0.5
        initalGoal.yScale = 0.5
        initalGoal.position = startRectLocalSpace.center
        addChild(initalGoal)
    }

    func attemptPlanetCreation(maxSafeAreaRadius: CGFloat,
                               minPlanetRadius: CGFloat,
                               minBoundsX: CGFloat,
                               maxBoundsX: CGFloat,
                               minBoundsY: CGFloat,
                               maxBoundsY: CGFloat,
                               startSafeArea: SKCircleRect,
                               goalSafeArea: SKCircleRect,
                               localSpacePlanets: [SKCircleRect]) -> (planet: Planet, rect: SKCircleRect, safe: SKCircleRect)? {

        let planetSafeAreaRadiusPaddingMultiplier: CGFloat = 1.5
        let maxPlanetSafeAreaRadius = maxSafeAreaRadius
        let maxPlanetRadius: CGFloat = maxPlanetSafeAreaRadius / planetSafeAreaRadiusPaddingMultiplier

        let planetRadius = CGFloat.random(in: minPlanetRadius...maxPlanetRadius)
        let planetRadiusSafeArea = planetRadius * planetSafeAreaRadiusPaddingMultiplier

        let planetMinCenterPositionX = minBoundsX + planetRadiusSafeArea
        let planetMaxCenterPositionX = maxBoundsX - planetRadiusSafeArea
        let planetMinCenterPositionY = minBoundsY + planetRadiusSafeArea
        let planetMaxCenterPositionY = maxBoundsY - planetRadiusSafeArea

        let planetPositionX = CGFloat.random(in: planetMinCenterPositionX...planetMaxCenterPositionX)
        let planetPositionY = CGFloat.random(in: planetMinCenterPositionY...planetMaxCenterPositionY)
        let planetPosition = CGPoint(x: planetPositionX, y: planetPositionY)

        let planetRect = SKCircleRect(centerX: planetPositionX,
                                      centerY: planetPositionY,
                                      radius: planetRadius)

        let planetSafeRect = SKCircleRect(centerX: planetPositionX,
                                          centerY: planetPositionY,
                                          radius: planetRadiusSafeArea)

        if planetSafeRect.intersects(circleRect: startSafeArea) ||
            planetSafeRect.intersects(circleRect: goalSafeArea) {
            return nil
        } else if !localSpacePlanets.filter({ $0.intersects(circleRect: planetSafeRect) }).isEmpty {
            return nil
        } else if !localSpacePlanets.filter({ $0.intersects(circleRect: planetSafeRect) }).isEmpty {
            return nil
        }
        viz(planetSafeRect: planetSafeRect.cgRect)

        let hues = (0...50).map({ $0 }) + (220...360).map({ $0 })
        let hue = CGFloat(hues.randomElement() ?? 0) / 360
        let planetColor = SKColor(hue: hue,
                                  saturation: 0.8,
                                  brightness: CGFloat.random(in: 0.8...1),
                                  alpha: 1)

        let planet = Planet(radius: planetRadius, color: planetColor)
        planet.zPosition = ZPosition.planet.rawValue
        planet.position = planetPosition
        addChild(planet)

        return (planet, planetRect, planetSafeRect)
    }

    // MARK: - Codable -

    enum CodingKeys: String, CodingKey {
        case number
        case position
        case goalRectLocalSpace
        case startRectLocalSpace
        case localSpacePlanets
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(number, forKey: .number)
        try container.encode(position, forKey: .position)
        try container.encode(goalRectLocalSpace, forKey: .goalRectLocalSpace)
        try container.encode(startRectLocalSpace, forKey: .startRectLocalSpace)
        try container.encode(localSpacePlanets, forKey: .localSpacePlanets)
    }

    required public convenience init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let number = try values.decode(Int.self, forKey: .number)
        let position = try values.decode(CGPoint.self, forKey: .position)
        let goalRectLocalSpace = try values.decode(SKCircleRect.self, forKey: .goalRectLocalSpace)
        let startRectLocalSpace = try values.decode(SKCircleRect.self, forKey: .startRectLocalSpace)
        let localSpacePlanets = try values.decode([Planet: SKCircleRect].self, forKey: .localSpacePlanets)

        self.init(number: number,
                  position: position,
                  goalRectLocalSpace: goalRectLocalSpace,
                  startRectLocalSpace: startRectLocalSpace,
                  localSpacePlanets: localSpacePlanets)
    }

    init(number: Int,
         position: CGPoint,
         goalRectLocalSpace: SKCircleRect,
         startRectLocalSpace: SKCircleRect,
         localSpacePlanets: [Planet: SKCircleRect]) {

        self.number = number
        self.goalRectLocalSpace = goalRectLocalSpace
        self.startRectLocalSpace = startRectLocalSpace
        self.localSpacePlanets = localSpacePlanets

        goalNode = Goal(levelNumber: number)
        goalNode.alpha = 0
        goalNode.position = goalRectLocalSpace.center

        super.init()

        name = number.description

        addChild(goalNode)
        self.position = position

        for (planet, rect) in localSpacePlanets {
            planet.position = rect.center
            addChild(planet)
        }
    }

    // MARK: - Viz -

    private func vizSize(size: CGSize) {
        if !Debugging.isLevelVizOn {
            return
        }
        let viz = SKShapeNode(rectOf: size)
        viz.fillColor = SKColor.blue.withAlphaComponent(0.15)
        addChild(viz)
    }

    private func viz(startBoundary: CGRect,
                     goalBoundary: CGRect,
                     planetBoundary: CGRect,
                     upperPlanetBoundary: CGRect,
                     lowerPlanetBoundary: CGRect) {
        if !Debugging.isLevelVizOn {
            return
        }
        let startPositionBoundaryNode = SKShapeNode(rect: startBoundary)
        startPositionBoundaryNode.fillColor = SKColor.blue.withAlphaComponent(0.5)
        addChild(startPositionBoundaryNode)

        let goalPositionBoundaryNode = SKShapeNode(rect: goalBoundary)
        goalPositionBoundaryNode.fillColor = SKColor.darkGray.withAlphaComponent(0.5)
        addChild(goalPositionBoundaryNode)

        let planetPositionBoundaryNode = SKShapeNode(rect: planetBoundary)
        planetPositionBoundaryNode.fillColor = SKColor.green.withAlphaComponent(0.5)
        addChild(planetPositionBoundaryNode)

        let upperPlanetPositionBoundaryNode = SKShapeNode(rect: upperPlanetBoundary)
        upperPlanetPositionBoundaryNode.fillColor = SKColor.red.withAlphaComponent(0.5)
        addChild(upperPlanetPositionBoundaryNode)

        let lowerPlanetPositionBoundaryNode = SKShapeNode(rect: lowerPlanetBoundary)
        lowerPlanetPositionBoundaryNode.fillColor = SKColor.red.withAlphaComponent(0.5)
        addChild(lowerPlanetPositionBoundaryNode)
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

            let goalViz = SKShapeNode(circleOfRadius: radius)
            goalViz.strokeColor = .white
            goalViz.position = CGPoint(x: goalPositionX, y: goalPositionY)
            addChild(goalViz)
        }
    }

}

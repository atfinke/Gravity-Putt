//
//  GameTests.swift
//  GameTests
//
//  Created by Andrew Finke on 4/8/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import XCTest
import SpriteKit

class GameTests: XCTestCase {

    func testPlanet() throws {
        let planet = Planet(radius: 12.5, color: .blue)
        let data = try JSONEncoder().encode(planet)
        
        let decoded = try JSONDecoder().decode(Planet.self, from: data)
        
        XCTAssertEqual(planet.radius, decoded.radius)
        XCTAssertEqual(planet.color, decoded.color)
    }
    
    func testRect() throws {
        let rect = SKCircleRect(center: CGPoint(x: 5, y: 12), radius: 20.5)
        let data = try JSONEncoder().encode(rect)
        
        let decoded = try JSONDecoder().decode(SKCircleRect.self, from: data)
        
        XCTAssertEqual(rect.radius, decoded.radius)
        XCTAssertEqual(rect.center, decoded.center)
    }
    
    func testLevel() throws {
        let level = LevelNode(size: CGSize(width: 1000, height: 800), number: 5)
        let data = try JSONEncoder().encode(level)
        
        let decoded = try JSONDecoder().decode(LevelNode.self, from: data)
        
        XCTAssertEqual(level.number, decoded.number)
        XCTAssertEqual(level.position, decoded.position)
        XCTAssertEqual(level.goalRectLocalSpace, decoded.goalRectLocalSpace)
        XCTAssertEqual(level.startRectLocalSpace, decoded.startRectLocalSpace)
        XCTAssertEqual(level.localSpacePlanets.count, decoded.localSpacePlanets.count)
        
        for levelPlanet in level.localSpacePlanets {
            var valid = false
            for decodedPlanet in decoded.localSpacePlanets {
                if levelPlanet.key.radius == decodedPlanet.key.radius && levelPlanet.key.position == decodedPlanet.key.position {
                    valid = true
                    break
                }
            }
            XCTAssertTrue(valid)
        }
    }
    
    func testLevels() throws {
        let levelOne = LevelNode(size: CGSize(width: 1000, height: 800), number: 5)
        let levelTwo = LevelNode(size: CGSize(width: 1000, height: 800), number: 15)
        let data = try JSONEncoder().encode([levelOne, levelTwo])
        
        let decoded = try JSONDecoder().decode([LevelNode].self, from: data)
        
        XCTAssertEqual(levelOne.number, decoded[0].number)
        XCTAssertEqual(levelOne.localSpacePlanets.count, decoded[0].localSpacePlanets.count)
        XCTAssertEqual(levelTwo.number, decoded[1].number)
        XCTAssertEqual(levelTwo.localSpacePlanets.count, decoded[1].localSpacePlanets.count)
    }
    
    func testGameScene() throws {
        let scene = GameScene(size: CGSize(width: 1000, height: 800))
        scene.setUpScene()
        
        sleep(2)
        
        let data = try JSONEncoder().encode(scene)
        
        let decoded = try JSONDecoder().decode(GameScene.self, from: data)
        
        XCTAssertEqual(scene.lastLevel, decoded.lastLevel)
        XCTAssertEqual(scene.levels.map({ $0.position }), decoded.levels.map({ $0.position }))
        XCTAssertEqual(scene.holeNumber, decoded.holeNumber)
        XCTAssertEqual(scene.holeScore, decoded.holeScore)
        XCTAssertEqual(scene.totalScore, decoded.totalScore)
    }

}

//
//  GravityGolfScreenshots_iOS.swift
//  GravityGolfScreenshots-iOS
//
//  Created by Andrew Finke on 4/14/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import XCTest

class GravityGolfScreenshots_iOS: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        setupSnapshot(app)
        app.launch()
        
        continueAfterFailure = false
    }

    func testScreenshots() throws {
        XCUIDevice.shared.orientation = .landscapeLeft
        sleep(0)
        snapshot("0")
        sleep(1)
        snapshot("1")
        sleep(4)
        snapshot("2")
    }
}
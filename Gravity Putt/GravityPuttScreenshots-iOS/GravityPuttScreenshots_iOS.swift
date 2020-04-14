//
//  GravityPuttScreenshots_iOS.swift
//  GravityPuttScreenshots-iOS
//
//  Created by Andrew Finke on 4/14/20.
//  Copyright © 2020 Andrew Finke. All rights reserved.
//

import XCTest

class GravityPuttScreenshots_iOS: XCTestCase {

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
        sleep(2)
        snapshot("1")
        sleep(3)
        snapshot("2")
    }
}

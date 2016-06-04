//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://www.jessesquires.com/JSQWebViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQWebViewController
//
//
//  License
//  Copyright (c) 2015 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

import UIKit
import XCTest


final class ExampleUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        XCUIApplication().launch()
    }
    
    override func tearDown() {
        super.tearDown()
    }
    
    func test_WebView_Push() {
        let app = XCUIApplication()

        app.tables.staticTexts["Push"].tap()
        XCTAssertTrue(app.webViews.count == 1)

        let navbar = app.navigationBars["jessesquires.com"]
        navbar.buttons["Share"].tap()
        XCTAssertTrue(app.sheets.count == 1)

        app.sheets.buttons["Cancel"].tap()
        XCTAssertTrue(app.sheets.count == 0)

        navbar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCTAssertTrue(app.webViews.count == 0)
    }

    func test_WebView_Modal() {
        let app = XCUIApplication()

        app.tables.staticTexts["Modal"].tap()
        XCTAssertTrue(app.webViews.count == 1)

        let navbar = app.navigationBars["jessesquires.com"]
        navbar.buttons["Share"].tap()
        XCTAssertTrue(app.sheets.count == 1)

        app.sheets.buttons["Cancel"].tap()
        XCTAssertTrue(app.sheets.count == 0)

        navbar.buttons["Done"].tap()
        XCTAssertTrue(app.webViews.count == 0)
    }

    func test_WebView_Storyboard() {
        let app = XCUIApplication()

        app.tables.staticTexts["Storyboard"].tap()
        XCTAssertTrue(app.webViews.count == 1)

        let navbar = app.navigationBars["jessesquires.com"]
        navbar.buttons["Share"].tap()
        XCTAssertTrue(app.sheets.count == 1)

        app.sheets.buttons["Cancel"].tap()
        XCTAssertTrue(app.sheets.count == 0)

        navbar.childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        XCTAssertTrue(app.webViews.count == 0)
    }
    
}

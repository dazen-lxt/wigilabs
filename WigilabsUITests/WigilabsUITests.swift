//
//  WigilabsUITests.swift
//  WigilabsUITests
//
//  Created by Carlos Muñoz on 01/07/26.
//

import XCTest

final class WigilabsUITests: XCTestCase {
    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testTabBarShowsVotingAndCatsTabs() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.tabBars.buttons["Votar"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.tabBars.buttons["Gatos"].exists)
    }

    func testVotingScreenShowsTitleAndVoteButtons() {
        let app = XCUIApplication()
        app.launch()

        XCTAssertTrue(app.navigationBars["Votar por raza"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Me gusta"].waitForExistence(timeout: 15))
        XCTAssertTrue(app.buttons["No me gusta"].exists)
    }

    func testHistorialButtonOpensVoteHistoryScreen() {
        let app = XCUIApplication()
        app.launch()

        app.navigationBars["Votar por raza"].buttons["Historial"].tap()
        XCTAssertTrue(app.navigationBars["Historial de votos"].waitForExistence(timeout: 5))

        app.navigationBars["Historial de votos"].buttons["Cerrar"].tap()
        XCTAssertTrue(app.navigationBars["Votar por raza"].waitForExistence(timeout: 5))
    }

    func testNavigatingToCatsTabShowsList() {
        let app = XCUIApplication()
        app.launch()

        app.tabBars.buttons["Gatos"].tap()
        XCTAssertTrue(app.navigationBars["Gatos"].waitForExistence(timeout: 5))
    }
}

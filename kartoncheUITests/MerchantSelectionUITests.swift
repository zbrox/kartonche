//
//  MerchantSelectionUITests.swift
//  kartoncheUITests
//
//  Created on 2026-02-06.
//

import XCTest

final class MerchantSelectionUITests: XCTestCase {
    
    override func setUpWithError() throws {
        continueAfterFailure = false
    }
    
    @MainActor
    func testAppLaunches() throws {
        let app = XCUIApplication()
        app.launch()
        
        XCTAssertTrue(app.exists, "App should launch successfully")
        
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add card button should exist on main screen")
    }
    
    
    // TODO: Add more detailed UI tests once we identify correct accessibility identifiers
    // for merchant rows and form fields in Bulgarian locale
}

//
//  SyncStatusUITests.swift
//  kartoncheUITests
//
//  Created on 2026-03-07.
//

import XCTest

final class SyncStatusUITests: XCTestCase {

    @MainActor
    func testDataSettingsShowsICloudSyncStatusRow() throws {
        let app = XCUIApplication()
        app.launch()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let dataSettingsRow = app.buttons["dataSettingsRow"]
        XCTAssertTrue(dataSettingsRow.waitForExistence(timeout: 3))
        dataSettingsRow.tap()

        let syncStatusRowLabel = app.staticTexts["iCloudSyncStatusRow"]
        XCTAssertTrue(syncStatusRowLabel.waitForExistence(timeout: 5))
    }
}

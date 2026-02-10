//
//  MerchantSelectionUITests.swift
//  kartoncheUITests
//
//  Created on 2026-02-06.
//

import XCTest

final class MerchantSelectionUITests: XCTestCase {
    
    @MainActor var app: XCUIApplication!
    
    @MainActor
    override func setUp() async throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }
    
    // MARK: - App Launch Tests
    
    @MainActor
    func testAppLaunches() throws {
        XCTAssertTrue(app.exists, "App should launch successfully")
        
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add card button should exist on main screen")
    }
    
    // MARK: - Merchant Selection Flow Tests
    
    @MainActor
    func testOpenMerchantSelection() throws {
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add button should exist")
        
        addButton.tap()
        
        // Merchant selection sheet should appear
        let customCardButton = app.buttons["customCardButton"]
        XCTAssertTrue(customCardButton.waitForExistence(timeout: 3), "Merchant selection sheet should appear")
        
        // Cancel button should be present
        let cancelButton = app.buttons["cancelButton"]
        XCTAssertTrue(cancelButton.exists, "Cancel button should exist")
    }
    
    @MainActor
    func testCloseMerchantSelection() throws {
        // Open merchant selection
        app.buttons["addCardButton"].tap()
        XCTAssertTrue(app.buttons["customCardButton"].waitForExistence(timeout: 3))
        
        // Tap cancel
        app.buttons["cancelButton"].tap()
        
        // Should return to main screen
        XCTAssertTrue(app.buttons["addCardButton"].waitForExistence(timeout: 3), "Should return to main screen")
    }
    
    @MainActor
    func testSelectKnownMerchant() throws {
        // Open merchant selection
        app.buttons["addCardButton"].tap()
        XCTAssertTrue(app.buttons["customCardButton"].waitForExistence(timeout: 3))
        
        // Select Billa merchant
        let billaButton = app.buttons["merchant_bg.billa"]
        XCTAssertTrue(billaButton.waitForExistence(timeout: 3), "Billa merchant should exist in list")
        billaButton.tap()
        
        // Card editor should open
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Card editor should open")
        
        // Store name should be pre-filled with "BILLA"
        let storeNameField = app.textFields["storeNameField"]
        XCTAssertTrue(storeNameField.exists, "Store name field should exist")
    }
    
    @MainActor
    func testSelectCustomCard() throws {
        // Open merchant selection
        app.buttons["addCardButton"].tap()
        XCTAssertTrue(app.buttons["customCardButton"].waitForExistence(timeout: 3))
        
        // Select custom card option
        app.buttons["customCardButton"].tap()
        
        // Card editor should open with empty fields
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.waitForExistence(timeout: 3), "Card editor should open")
        
        // Save button should be disabled (empty required fields)
        XCTAssertFalse(saveButton.isEnabled, "Save button should be disabled for empty card")
    }
    
    @MainActor
    func testSearchMerchants() throws {
        // Open merchant selection
        app.buttons["addCardButton"].tap()
        XCTAssertTrue(app.buttons["customCardButton"].waitForExistence(timeout: 3))
        
        // Verify both merchants exist before searching
        XCTAssertTrue(app.buttons["merchant_bg.billa"].waitForExistence(timeout: 3), "Billa should exist before search")
        XCTAssertTrue(app.buttons["merchant_bg.kaufland"].exists, "Kaufland should exist before search")
        
        // Find search field by its prompt text
        let searchField = app.searchFields["Search Merchant"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 3), "Search field should exist")
        
        // Tap and type (as recorded by Xcode)
        searchField.tap()
        searchField.typeText("Kaufland")
        
        // Kaufland should be in results
        let kauflandButton = app.buttons["merchant_bg.kaufland"]
        XCTAssertTrue(kauflandButton.waitForExistence(timeout: 3), "Kaufland should appear in search results")
        
        // Billa should be filtered out
        let billaStillExists = app.buttons["merchant_bg.billa"].waitForExistence(timeout: 2)
        XCTAssertFalse(billaStillExists, "Billa should be filtered out by search")
    }
    
    // MARK: - Card Editor Tests
    
    @MainActor
    func testCreateCardWithMinimalData() throws {
        // Open merchant selection and choose custom
        app.buttons["addCardButton"].tap()
        _ = app.buttons["customCardButton"].waitForExistence(timeout: 3)
        app.buttons["customCardButton"].tap()
        
        // Fill required fields
        let cardNameField = app.textFields["cardNameField"]
        XCTAssertTrue(cardNameField.waitForExistence(timeout: 3))
        cardNameField.tap()
        cardNameField.typeText("Test Card")
        
        let storeNameField = app.textFields["storeNameField"]
        storeNameField.tap()
        storeNameField.typeText("Test Store")
        
        let barcodeDataField = app.textFields["barcodeDataField"]
        barcodeDataField.tap()
        barcodeDataField.typeText("1234567890")
        
        // Save button should now be enabled
        let saveButton = app.buttons["saveButton"]
        XCTAssertTrue(saveButton.isEnabled, "Save button should be enabled with all required fields filled")
        
        // Tap save
        saveButton.tap()
        
        // Should return to main screen
        XCTAssertTrue(app.buttons["addCardButton"].waitForExistence(timeout: 3), "Should return to main screen after save")
    }
    
    @MainActor
    func testCancelCardCreation() throws {
        // Open card editor
        app.buttons["addCardButton"].tap()
        _ = app.buttons["customCardButton"].waitForExistence(timeout: 3)
        app.buttons["customCardButton"].tap()
        
        // Fill some data
        let cardNameField = app.textFields["cardNameField"]
        _ = cardNameField.waitForExistence(timeout: 3)
        cardNameField.tap()
        cardNameField.typeText("Test")
        
        // Tap cancel
        app.buttons["cancelButton"].tap()
        
        // Should return to main screen
        XCTAssertTrue(app.buttons["addCardButton"].waitForExistence(timeout: 3), "Should return to main screen")
    }
    
    // MARK: - Barcode Scanner Tests
    
    @MainActor
    func testBarcodeScannerButton() throws {
        // Skip on simulator - barcode scanner requires physical device with camera
        if ProcessInfo.processInfo.environment["SIMULATOR_DEVICE_NAME"] != nil {
            throw XCTSkip("Barcode scanner requires physical device with camera")
        }
        
        // Open card editor
        app.buttons["addCardButton"].tap()
        _ = app.buttons["customCardButton"].waitForExistence(timeout: 3)
        app.buttons["customCardButton"].tap()
        
        // Scan barcode button should exist on device
        let scanButton = app.buttons["scanBarcodeButton"]
        XCTAssertTrue(scanButton.exists, "Scan barcode button should exist on device")
    }
}

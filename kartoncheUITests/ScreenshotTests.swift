//
//  ScreenshotTests.swift
//  kartoncheUITests
//

@preconcurrency import XCTest

final class ScreenshotTests: XCTestCase {

    nonisolated(unsafe) var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        // XCTest runs setUp on the main thread
        let application: XCUIApplication = MainActor.assumeIsolated {
            let a = XCUIApplication()
            a.launchArguments += ["--screenshot-mode"]
            return a
        }
        app = application
    }

    @MainActor private func capture(_ name: String) {
        let attachment = XCTAttachment(screenshot: app.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }

    // MARK: - Screenshots

    @MainActor
    func testCardList() throws {
        app.launch()

        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5), "Card list should show sample cards")

        capture("01-card-list")
    }

    @MainActor
    func testCardDisplay() throws {
        app.launch()

        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()

        // The accessibility identifier may be exposed as any element type depending on SwiftUI rendering
        let barcodeImage = app.descendants(matching: .any)["barcodeImage"]
        XCTAssertTrue(barcodeImage.waitForExistence(timeout: 10), "Barcode display should appear")

        capture("02-card-display")
    }

    @MainActor
    func testCardEditor() throws {
        app.launch()

        // Open editor for Downtown Gym (4th card, index 3)
        let gymCard = app.cells.element(boundBy: 3)
        XCTAssertTrue(gymCard.waitForExistence(timeout: 5))

        gymCard.press(forDuration: 1.0)
        let editButton = app.buttons["contextMenuEdit"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3))
        editButton.tap()

        let cardNameField = app.textFields["cardNameField"]
        XCTAssertTrue(cardNameField.waitForExistence(timeout: 3))

        capture("03-card-edit")
    }

    @MainActor
    func testWalletPass() throws {
        app.launch()

        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()

        let walletButton = app.buttons["addToWalletButton"]
        XCTAssertTrue(walletButton.waitForExistence(timeout: 10), "Add to Wallet button should appear")
        walletButton.tap()

        // Wait for pass generation and the system Add Pass sheet
        sleep(3)

        capture("04-wallet-pass")

        // Dismiss any system sheet so the next test can launch cleanly
        app.swipeDown()
    }

    @MainActor
    func testAddLocation() throws {
        app.launch()

        // Open editor for Fresh Market (2nd card, index 1) — has a seeded location
        let freshMarket = app.cells.element(boundBy: 1)
        XCTAssertTrue(freshMarket.waitForExistence(timeout: 5))

        freshMarket.press(forDuration: 1.0)
        let editButton = app.buttons["contextMenuEdit"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3))
        editButton.tap()

        // Wait for editor to appear then scroll until Add Location is visible
        let cardNameField = app.textFields["cardNameField"]
        XCTAssertTrue(cardNameField.waitForExistence(timeout: 3))

        let addLocationButton = app.buttons["addLocationButton"]
        for _ in 0..<5 {
            if addLocationButton.isHittable { break }
            app.swipeUp()
        }
        XCTAssertTrue(addLocationButton.isHittable, "Add Location button should be visible")
        addLocationButton.tap()

        let dropPinButton = app.buttons["dropPinOnMapButton"]
        XCTAssertTrue(dropPinButton.waitForExistence(timeout: 5))
        dropPinButton.tap()

        // Wait for map to render
        sleep(3)

        capture("05-add-location")
    }

    @MainActor
    func testExportSelection() throws {
        app.launch()

        let settingsButton = app.buttons["settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 5))
        settingsButton.tap()

        let dataRow = app.buttons["dataSettingsRow"]
        XCTAssertTrue(dataRow.waitForExistence(timeout: 3))
        dataRow.tap()

        let selectCardsRow = app.buttons["selectCardsToExportRow"]
        XCTAssertTrue(selectCardsRow.waitForExistence(timeout: 3))
        selectCardsRow.tap()

        // Select all cards to show the selection UI
        let selectAllButton = app.buttons["selectAllButton"]
        if selectAllButton.waitForExistence(timeout: 3) {
            selectAllButton.tap()
        }

        capture("06-export")
    }
}

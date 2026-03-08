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
    func testPhotoScan() throws {
        app.launch()

        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let addManually = app.buttons["addManuallyButton"]
        XCTAssertTrue(addManually.waitForExistence(timeout: 3))
        addManually.tap()

        let cardNameField = app.textFields["cardNameField"]
        XCTAssertTrue(cardNameField.waitForExistence(timeout: 3))

        capture("03-photo-scan")
    }

    @MainActor
    func testWalletPass() throws {
        app.launch()

        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()

        let walletButton = app.buttons["addToWalletButton"]
        XCTAssertTrue(walletButton.waitForExistence(timeout: 10), "Add to Wallet button should appear")

        capture("04-wallet-pass")
    }

    @MainActor
    func testAddLocation() throws {
        app.launch()

        // Open editor for a card that has a location (Fresh Market)
        let freshMarket = app.cells.element(boundBy: 1)
        XCTAssertTrue(freshMarket.waitForExistence(timeout: 5))

        freshMarket.press(forDuration: 1.0)
        let editButton = app.buttons["contextMenuEdit"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 3))
        editButton.tap()

        // Wait for editor to appear then scroll to locations
        let cardNameField = app.textFields["cardNameField"]
        XCTAssertTrue(cardNameField.waitForExistence(timeout: 3))
        app.swipeUp()

        capture("05-add-location")
    }

    @MainActor
    func testShareExport() throws {
        app.launch()

        let firstCard = app.cells.firstMatch
        XCTAssertTrue(firstCard.waitForExistence(timeout: 5))
        firstCard.tap()

        let shareButton = app.buttons["shareCardButton"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 10))
        shareButton.tap()

        // Wait for the system share sheet to appear
        let shareSheet = app.navigationBars["UIActivityContentView"]
        if !shareSheet.waitForExistence(timeout: 5) {
            // Fallback: some iOS versions use a different identifier
            sleep(2)
        }

        capture("06-share-export")
    }
}

//
//  QuickScanUITests.swift
//  kartoncheUITests
//

import XCTest

final class QuickScanUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()
    }

    // MARK: - Helpers

    /// Waits for an element to disappear within the given timeout.
    @MainActor
    private func waitForDisappearance(of element: XCUIElement, timeout: TimeInterval = 3) {
        let predicate = NSPredicate(format: "exists == false")
        let expectation = XCTNSPredicateExpectation(predicate: predicate, object: element)
        let result = XCTWaiter.wait(for: [expectation], timeout: timeout)
        XCTAssertEqual(result, .completed, "\(element) should disappear within \(timeout)s")
    }

    /// Asserts that a text field is empty by checking that its value matches its placeholder.
    /// UITextField reports placeholder text as value when the field is empty.
    @MainActor
    private func assertFieldIsEmpty(_ field: XCUIElement, placeholderContains: String) {
        let value = field.value as? String ?? ""
        let isEmpty = value.isEmpty || value.contains(placeholderContains)
        XCTAssertTrue(isEmpty, "Field should be empty (got value: '\(value)')")
    }

    /// Taps the cancel action of the currently presented add-card dialog.
    @MainActor
    private func dismissAddDialog(_ sheet: XCUIElement) {
        // Prefer gesture dismissal to avoid selecting any dialog action.
        sheet.swipeDown()
        if !sheet.exists {
            return
        }

        let window = app.windows.element(boundBy: 0)
        if window.exists {
            // Top edge tap is outside the action sheet on iPhone layouts.
            window.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.02)).tap()
            if !sheet.exists {
                return
            }
        }

        let cancelLabels = ["Cancel", "Отказ"]
        for label in cancelLabels {
            let cancel = sheet.buttons[label]
            if cancel.exists {
                cancel.tap()
                return
            }
        }

        let fallbackCancel = sheet.buttons.element(boundBy: sheet.buttons.count - 1)
        fallbackCancel.tap()
    }

    // MARK: - Add dialog

    @MainActor
    func testAddButtonShowsThreeOptions() throws {
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5), "Add Card button should exist")
        addButton.tap()

        let takePhoto = app.buttons["Take a Photo"]
        let chooseLibrary = app.buttons["Choose from Library"]
        let addManually = app.buttons["Add Manually"]

        XCTAssertTrue(takePhoto.waitForExistence(timeout: 3), "Take a Photo option should appear")
        XCTAssertTrue(chooseLibrary.exists, "Choose from Library option should appear")
        XCTAssertTrue(addManually.exists, "Add Manually option should appear")
    }

    @MainActor
    func testAddManuallyOpensEmptyEditor() throws {
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let addManually = app.buttons["Add Manually"]
        XCTAssertTrue(addManually.waitForExistence(timeout: 3))
        addManually.tap()

        let cardNameField = app.textFields["cardNameField"]
        XCTAssertTrue(cardNameField.waitForExistence(timeout: 3), "Card editor should open")

        let barcodeDataField = app.textFields["barcodeDataField"]
        XCTAssertTrue(barcodeDataField.exists)
        assertFieldIsEmpty(barcodeDataField, placeholderContains: "Barcode")
    }

    @MainActor
    func testCancelDismissesDialog() throws {
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let takePhoto = app.buttons["Take a Photo"]
        XCTAssertTrue(takePhoto.waitForExistence(timeout: 3))

        // iOS confirmationDialog action sheets have a system Cancel button in the sheets collection
        let sheets = app.sheets
        XCTAssertTrue(sheets.element.exists, "Action sheet should be presented")
        dismissAddDialog(sheets.element)

        waitForDisappearance(of: takePhoto)
    }

    @MainActor
    func testEditorCancelReturnsToList() throws {
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))
        addButton.tap()

        let addManually = app.buttons["Add Manually"]
        XCTAssertTrue(addManually.waitForExistence(timeout: 3))
        addManually.tap()

        let cancelButton = app.buttons["cancelButton"]
        XCTAssertTrue(cancelButton.waitForExistence(timeout: 3))
        cancelButton.tap()

        XCTAssertTrue(addButton.waitForExistence(timeout: 3), "Should return to card list after cancel")
    }

    @MainActor
    func testAddAfterCancelDoesNotLeakStaleState() throws {
        let addButton = app.buttons["addCardButton"]
        XCTAssertTrue(addButton.waitForExistence(timeout: 5))

        // First: open dialog and dismiss it
        addButton.tap()
        let takePhoto = app.buttons["Take a Photo"]
        XCTAssertTrue(takePhoto.waitForExistence(timeout: 3))

        let sheets = app.sheets
        dismissAddDialog(sheets.element)
        waitForDisappearance(of: takePhoto)

        // Defensive: if an action was selected while dismissing, close editor and continue from list.
        let editorCancel = app.buttons["cancelButton"]
        if editorCancel.exists {
            editorCancel.tap()
        }

        XCTAssertTrue(addButton.waitForExistence(timeout: 3))

        let addManually = app.buttons["Add Manually"]

        // Second: open and add manually (retry to avoid transient post-dismiss timing races)
        var didOpenAddDialog = false
        for _ in 0..<3 {
            addButton.tap()
            if addManually.waitForExistence(timeout: 2) {
                didOpenAddDialog = true
                break
            }
        }
        XCTAssertTrue(didOpenAddDialog)
        addManually.tap()

        let barcodeDataField = app.textFields["barcodeDataField"]
        XCTAssertTrue(barcodeDataField.waitForExistence(timeout: 3))
        assertFieldIsEmpty(barcodeDataField, placeholderContains: "Barcode")
    }
}

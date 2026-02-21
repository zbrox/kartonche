//
//  ViewErrorAlertTests.swift
//  kartoncheTests
//
//  Created on 2026-02-21.
//

import Foundation
import Testing
@testable import kartonche

struct ViewErrorAlertTests {
    private struct StubError: LocalizedError {
        let errorDescription: String?
    }

    @Test @MainActor func cardListShareAlertIncludesErrorMessage() {
        let alert = CardListErrorAlert.shareFailed(StubError(errorDescription: "Disk full"))
        #expect(alert.message == "Disk full")
    }

    @Test @MainActor func cardListImportAlertIncludesErrorMessage() {
        let alert = CardListErrorAlert.importFailed(StubError(errorDescription: "Invalid file"))
        #expect(alert.message == "Invalid file")
    }

    @Test @MainActor func cardDisplayShareAlertIncludesErrorMessage() {
        let alert = CardDisplayErrorAlert.shareFailed(StubError(errorDescription: "Write failed"))
        #expect(alert.message == "Write failed")
    }
}

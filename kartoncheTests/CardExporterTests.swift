//
//  CardExporterTests.swift
//  kartoncheTests
//
//  Created on 2026-02-21.
//

import Foundation
import Testing
@testable import kartonche

@MainActor
struct CardExporterTests {
    @Test func createShareFileForCardProducesKartoncheFile() throws {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Store",
            cardNumber: "123",
            barcodeType: .qr,
            barcodeData: "DATA123"
        )

        let fileURL = try CardExporter.createShareFile(for: card)
        defer { try? FileManager.default.removeItem(at: fileURL) }

        #expect(fileURL.pathExtension == "kartonche")

        let data = try Data(contentsOf: fileURL)
        let container = try CardImporter.importFromData(data)
        #expect(container.cards.count == 1)
        #expect(container.cards.first?.name == "Test Card")
    }
}

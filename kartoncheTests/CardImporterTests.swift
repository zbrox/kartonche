//
//  CardImporterTests.swift
//  kartoncheTests
//
//  Created on 2026-02-21.
//

import Foundation
import Testing
@testable import kartonche

struct CardImporterTests {
    @Test @MainActor func detectDuplicatesDoesNotMatchWhenStoreAndCardNumberMissing() {
        let imported = CardExportDTO(
            id: UUID(),
            name: "Imported",
            storeName: nil,
            cardNumber: nil,
            barcodeType: .qr,
            barcodeData: "IMPORTED-1",
            color: nil,
            secondaryColor: nil,
            notes: nil,
            cardholderName: nil,
            isFavorite: false,
            createdDate: Date(),
            lastUsedDate: nil,
            expirationDate: nil,
            cardImage: nil,
            locations: []
        )

        let existing = LoyaltyCard(
            name: "Existing",
            storeName: nil,
            cardNumber: nil,
            barcodeType: .qr,
            barcodeData: "EXISTING-1"
        )

        let duplicates = CardImporter.detectDuplicates([imported], existingCards: [existing])
        #expect(duplicates.isEmpty)
    }

    @Test @MainActor func detectDuplicatesMatchesWhenStoreAndCardNumberMatch() {
        let imported = CardExportDTO(
            id: UUID(),
            name: "Imported",
            storeName: "Store",
            cardNumber: "12345",
            barcodeType: .qr,
            barcodeData: "IMPORTED-2",
            color: nil,
            secondaryColor: nil,
            notes: nil,
            cardholderName: nil,
            isFavorite: false,
            createdDate: Date(),
            lastUsedDate: nil,
            expirationDate: nil,
            cardImage: nil,
            locations: []
        )

        let existing = LoyaltyCard(
            name: "Existing",
            storeName: "Store",
            cardNumber: "12345",
            barcodeType: .qr,
            barcodeData: "EXISTING-2"
        )

        let duplicates = CardImporter.detectDuplicates([imported], existingCards: [existing])
        #expect(duplicates.count == 1)
    }
}

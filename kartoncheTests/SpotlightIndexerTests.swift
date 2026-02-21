//
//  SpotlightIndexerTests.swift
//  kartoncheTests
//
//  Created on 2026-02-18.
//

import Testing
import CoreSpotlight
@testable import kartonche

@MainActor
struct SpotlightIndexerTests {

    @Test func fullCardProducesCompleteAttributes() {
        let card = LoyaltyCard(
            name: "Billa Club",
            storeName: "Billa",
            cardNumber: "1234567890",
            barcodeType: .ean13,
            barcodeData: "1234567890",
            notes: "VIP member",
            cardholderName: "Rostislav Raykov"
        )

        let item = SpotlightIndexer.searchableItem(for: card)

        #expect(item.uniqueIdentifier == card.id.uuidString)
        #expect(item.domainIdentifier == SpotlightIndexer.domainIdentifier)
        #expect(item.expirationDate == .distantFuture)

        let attrs = item.attributeSet
        #expect(attrs.title == "Billa Club")
        #expect(attrs.contentDescription == "Billa · 1234567890 · Rostislav Raykov · VIP member")
        #expect(attrs.keywords == ["Billa", "1234567890", "Rostislav Raykov"])
    }

    @Test func minimalCardProducesGracefulAttributes() {
        let card = LoyaltyCard(
            name: "Simple Card",
            barcodeType: .qr,
            barcodeData: "ABC"
        )

        let item = SpotlightIndexer.searchableItem(for: card)

        #expect(item.attributeSet.title == "Simple Card")
        #expect(item.attributeSet.contentDescription == nil)
        #expect(item.attributeSet.keywords?.isEmpty ?? true)
    }

    @Test func partialOptionalsIncludeOnlyPopulatedFields() {
        let card = LoyaltyCard(
            name: "Partial Card",
            storeName: "Some Store",
            barcodeType: .code128,
            barcodeData: "DATA",
            notes: "A note"
        )

        let attrs = SpotlightIndexer.searchableItem(for: card).attributeSet

        #expect(attrs.contentDescription == "Some Store · A note")
        #expect(attrs.keywords == ["Some Store"])
    }

    @Test func emptyStringsAreExcludedFromDescription() {
        let card = LoyaltyCard(
            name: "Edge Case",
            storeName: "",
            cardNumber: "",
            barcodeType: .qr,
            barcodeData: "X",
            notes: "",
            cardholderName: ""
        )

        let attrs = SpotlightIndexer.searchableItem(for: card).attributeSet

        #expect(attrs.contentDescription == nil)
        #expect(attrs.keywords?.isEmpty ?? true)
    }
}

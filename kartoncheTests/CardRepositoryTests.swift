//
//  CardRepositoryTests.swift
//  kartoncheTests
//
//  Created on 2026-02-18.
//

import Foundation
import Testing
import SwiftData
@testable import kartonche

@MainActor
struct CardRepositoryTests {

    private func makeContainer() throws -> ModelContainer {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        return try ModelContainer(for: LoyaltyCard.self, CardLocation.self, configurations: config)
    }

    @Test func deleteRemovesCardFromContext() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let card = LoyaltyCard(
            name: "Test Card",
            barcodeType: .qr,
            barcodeData: "12345"
        )
        context.insert(card)
        try context.save()

        let repo = CardRepository(modelContext: context)
        repo.delete(card)
        try context.save()

        let remaining = try context.fetch(FetchDescriptor<LoyaltyCard>())
        #expect(remaining.isEmpty)
    }

    @Test func deleteRemovesCardWithLocations() throws {
        let container = try makeContainer()
        let context = container.mainContext
        let card = LoyaltyCard(
            name: "Card With Location",
            barcodeType: .code128,
            barcodeData: "LOC123"
        )
        context.insert(card)
        let location = CardLocation(
            name: "Store",
            address: "123 Main St",
            latitude: 42.0,
            longitude: 23.0,
            radius: 100
        )
        location.card = card
        context.insert(location)
        try context.save()

        let repo = CardRepository(modelContext: context)
        repo.delete(card)
        try context.save()

        let remainingCards = try context.fetch(FetchDescriptor<LoyaltyCard>())
        let remainingLocations = try context.fetch(FetchDescriptor<CardLocation>())
        #expect(remainingCards.isEmpty)
        #expect(remainingLocations.isEmpty)
    }

    @Test func importCardsInsertsCards() throws {
        let container = try makeContainer()
        let context = container.mainContext

        let dto = CardExportDTO(
            id: UUID(),
            name: "Imported Card",
            storeName: "Test Store",
            cardNumber: "999",
            barcodeType: .qr,
            barcodeData: "IMPORT123",
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
        let exportContainer = CardExportContainer(cards: [dto])

        let repo = CardRepository(modelContext: context)
        let result = try repo.importCards(from: exportContainer, strategy: .keepBoth)

        #expect(result.importedCount == 1)
        #expect(result.hasChanges)

        let cards = try context.fetch(FetchDescriptor<LoyaltyCard>())
        #expect(cards.count == 1)
        #expect(cards.first?.name == "Imported Card")
    }

    @Test func importCardsWithNoChangesReportsNoChanges() throws {
        let container = try makeContainer()
        let context = container.mainContext

        // Insert existing card that will match the imported one
        let existingCard = LoyaltyCard(
            name: "Existing",
            storeName: "Store",
            cardNumber: "111",
            barcodeType: .qr,
            barcodeData: "DATA"
        )
        context.insert(existingCard)
        try context.save()

        let dto = CardExportDTO(
            id: UUID(),
            name: "Existing",
            storeName: "Store",
            cardNumber: "111",
            barcodeType: .qr,
            barcodeData: "DATA",
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
        let exportContainer = CardExportContainer(cards: [dto])

        let repo = CardRepository(modelContext: context)
        let result = try repo.importCards(from: exportContainer, strategy: .skipDuplicates)

        #expect(result.importedCount == 0)
        #expect(result.skippedCount == 1)
        #expect(!result.hasChanges)
    }
}

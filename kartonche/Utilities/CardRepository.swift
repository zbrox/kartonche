//
//  CardRepository.swift
//  kartonche
//
//  Created on 2026-02-18.
//

import SwiftData
import WidgetKit
import PassKit

/// Centralizes card mutation side-effects (notifications, widgets, wallet passes)
@MainActor
final class CardRepository {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Run all post-save side-effects for a card.
    /// The caller is responsible for setting properties and inserting new cards beforehand.
    func save(_ card: LoyaltyCard) {
        Task {
            if card.expirationDate != nil {
                await NotificationManager.shared.scheduleExpirationNotifications(for: card)
            } else {
                await NotificationManager.shared.cancelNotifications(for: card.id)
            }
        }

        WidgetCenter.shared.reloadAllTimelines()

        if walletPassExists(for: card) {
            Task {
                try? await updateWalletPass(for: card)
            }
        }

        SpotlightIndexer.index(card)
    }

    /// Handle all cleanup before deletion, then delete the card.
    func delete(_ card: LoyaltyCard) {
        Task {
            await NotificationManager.shared.cancelNotifications(for: card.id)
        }

        removeWalletPass(for: card)
        SpotlightIndexer.deindex(card)

        modelContext.delete(card)

        WidgetCenter.shared.reloadAllTimelines()
    }

    /// Import cards from an export container with the given strategy.
    func importCards(
        from container: CardExportContainer,
        strategy: CardImporter.ImportStrategy
    ) throws -> CardImporter.ImportResult {
        let result = try CardImporter.importCards(
            from: container,
            into: modelContext,
            strategy: strategy
        )

        if result.hasChanges {
            WidgetCenter.shared.reloadAllTimelines()

            let allCards = try modelContext.fetch(FetchDescriptor<LoyaltyCard>())
            SpotlightIndexer.reindexAll(allCards)
        }

        return result
    }

    // MARK: - Wallet Pass Helpers

    private func walletPassExists(for card: LoyaltyCard) -> Bool {
        PKPassLibrary().passes().contains {
            $0.serialNumber == card.id.uuidString &&
            $0.passTypeIdentifier == WalletPassConfiguration.passTypeIdentifier
        }
    }

    private func updateWalletPass(for card: LoyaltyCard) async throws {
        let passData = try WalletPassGenerator.generate(for: card)
        let pass = try PKPass(data: passData)
        PKPassLibrary().replacePass(with: pass)
    }

    private func removeWalletPass(for card: LoyaltyCard) {
        if let pass = PKPassLibrary().passes().first(where: {
            $0.serialNumber == card.id.uuidString &&
            $0.passTypeIdentifier == WalletPassConfiguration.passTypeIdentifier
        }) {
            PKPassLibrary().removePass(pass)
        }
    }
}

//
//  SpotlightIndexer.swift
//  kartonche
//
//  Created on 2026-02-18.
//

import CoreSpotlight

enum SpotlightIndexer {
    static let domainIdentifier = "com.zbrox.kartonche.cards"

    static func index(_ card: LoyaltyCard) {
        let item = searchableItem(for: card)
        Task {
            try? await CSSearchableIndex.default().indexSearchableItems([item])
        }
    }

    static func deindex(_ card: LoyaltyCard) {
        let identifier = card.id.uuidString
        Task {
            try? await CSSearchableIndex.default().deleteSearchableItems(withIdentifiers: [identifier])
        }
    }

    static func reindexAll(_ cards: [LoyaltyCard]) {
        let items = cards.map { searchableItem(for: $0) }
        Task {
            try? await CSSearchableIndex.default().deleteSearchableItems(withDomainIdentifiers: [domainIdentifier])
            try? await CSSearchableIndex.default().indexSearchableItems(items)
        }
    }

    // MARK: - Internal (visible to @testable import)

    static func searchableItem(for card: LoyaltyCard) -> CSSearchableItem {
        let attributes = CSSearchableItemAttributeSet(contentType: .content)
        attributes.title = card.name

        let descriptionParts = [card.storeName, card.cardNumber, card.cardholderName, card.notes]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
        if !descriptionParts.isEmpty {
            attributes.contentDescription = descriptionParts.joined(separator: " · ")
        }

        attributes.keywords = [card.storeName, card.cardNumber, card.cardholderName]
            .compactMap { $0 }
            .filter { !$0.isEmpty }

        let item = CSSearchableItem(
            uniqueIdentifier: card.id.uuidString,
            domainIdentifier: domainIdentifier,
            attributeSet: attributes
        )
        item.expirationDate = .distantFuture

        return item
    }
}

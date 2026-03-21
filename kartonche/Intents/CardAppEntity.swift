//
//  CardAppEntity.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents
import Foundation

struct CardAppEntity: AppEntity {
    let id: UUID
    let name: String
    let storeName: String?
    let barcodeType: BarcodeType
    let barcodeData: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Loyalty Card")
    }

    nonisolated(unsafe) static var defaultQuery = CardAppEntityQuery()

    var displayRepresentation: DisplayRepresentation {
        if let storeName, !storeName.isEmpty {
            return DisplayRepresentation(title: "\(name)", subtitle: "\(storeName)")
        }
        return DisplayRepresentation(title: "\(name)")
    }
}

struct CardAppEntityQuery: EntityStringQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [CardAppEntity] {
        let allCards = SharedDataManager.fetchAllCards()
        return allCards
            .filter { identifiers.contains($0.id) }
            .map { CardAppEntity(id: $0.id, name: $0.name, storeName: $0.storeName, barcodeType: $0.barcodeType, barcodeData: $0.barcodeData) }
    }

    @MainActor
    func entities(matching string: String) async throws -> [CardAppEntity] {
        let allCards = SharedDataManager.fetchAllCards()
        let query = string.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        return allCards
            .filter { card in
                let name = card.name.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                let store = (card.storeName ?? "").lowercased().folding(options: .diacriticInsensitive, locale: .current)
                return name.contains(query) || store.contains(query)
            }
            .map { CardAppEntity(id: $0.id, name: $0.name, storeName: $0.storeName, barcodeType: $0.barcodeType, barcodeData: $0.barcodeData) }
    }

    @MainActor
    func suggestedEntities() async throws -> [CardAppEntity] {
        let allCards = SharedDataManager.fetchAllCards()
        return allCards.map { CardAppEntity(id: $0.id, name: $0.name, storeName: $0.storeName, barcodeType: $0.barcodeType, barcodeData: $0.barcodeData) }
    }

    @MainActor
    func defaultResult() async -> CardAppEntity? {
        let allCards = SharedDataManager.fetchAllCards()
        guard let first = allCards.first else { return nil }
        return CardAppEntity(id: first.id, name: first.name, storeName: first.storeName, barcodeType: first.barcodeType, barcodeData: first.barcodeData)
    }
}

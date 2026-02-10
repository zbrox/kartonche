//
//  AppIntent.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import WidgetKit
import AppIntents
import Foundation

struct CardEntity: AppEntity {
    let id: UUID
    let name: String
    let storeName: String
    
    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Loyalty Card")
    }
    
    static var defaultQuery = CardEntityQuery()
    
    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", subtitle: "\(storeName)")
    }
}

struct CardEntityQuery: EntityQuery {
    @MainActor
    func entities(for identifiers: [UUID]) async throws -> [CardEntity] {
        let allCards = SharedDataManager.fetchAllCards()
        return allCards
            .filter { identifiers.contains($0.id) }
            .map { CardEntity(id: $0.id, name: $0.name, storeName: $0.storeName) }
    }
    
    @MainActor
    func suggestedEntities() async throws -> [CardEntity] {
        let allCards = SharedDataManager.fetchAllCards()
        return allCards.map { CardEntity(id: $0.id, name: $0.name, storeName: $0.storeName) }
    }
    
    @MainActor
    func defaultResult() async -> CardEntity? {
        let allCards = SharedDataManager.fetchAllCards()
        guard let firstCard = allCards.first else { return nil }
        return CardEntity(id: firstCard.id, name: firstCard.name, storeName: firstCard.storeName)
    }
}

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource { "Select Card" }
    static var description: IntentDescription { "Choose which loyalty card to display" }

    @Parameter(title: "Card")
    var card: CardEntity?
}

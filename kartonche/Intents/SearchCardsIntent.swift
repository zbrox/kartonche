//
//  SearchCardsIntent.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents

struct SearchCardsIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Search Cards"
    nonisolated(unsafe) static var description: IntentDescription = "Searches your loyalty cards by name or store"
    nonisolated(unsafe) static var openAppWhenRun: Bool = false

    @Parameter(title: "Search Query")
    var query: String

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<[CardAppEntity]> {
        let allCards = SharedDataManager.fetchAllCards()
        let search = query.lowercased().folding(options: .diacriticInsensitive, locale: .current)
        let matching = allCards
            .filter { card in
                let name = card.name.lowercased().folding(options: .diacriticInsensitive, locale: .current)
                let store = (card.storeName ?? "").lowercased().folding(options: .diacriticInsensitive, locale: .current)
                return name.contains(search) || store.contains(search)
            }
            .map { CardAppEntity(id: $0.id, name: $0.name, storeName: $0.storeName, barcodeType: $0.barcodeType, barcodeData: $0.barcodeData) }
        return .result(value: matching)
    }
}

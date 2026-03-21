//
//  GetCardBarcodeIntent.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents

struct CardBarcodeResult: AppEntity {
    let id: UUID
    let barcodeType: BarcodeType
    let barcodeData: String

    static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Card Barcode")
    }

    nonisolated(unsafe) static var defaultQuery = CardBarcodeResultQuery()

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(barcodeType.rawValue)", subtitle: "\(barcodeData)")
    }
}

struct CardBarcodeResultQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [CardBarcodeResult] {
        []
    }
}

struct GetCardBarcodeIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Get Card Barcode"
    nonisolated(unsafe) static var description: IntentDescription = "Returns the barcode type and data for a loyalty card"
    nonisolated(unsafe) static var openAppWhenRun: Bool = false

    @Parameter(title: "Card")
    var card: CardAppEntity

    func perform() async throws -> some IntentResult & ReturnsValue<CardBarcodeResult> {
        let result = CardBarcodeResult(
            id: card.id,
            barcodeType: card.barcodeType,
            barcodeData: card.barcodeData
        )
        return .result(value: result)
    }
}

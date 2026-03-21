//
//  ShowCardIntent.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents
import Foundation

struct ShowCardIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Show Card"
    nonisolated(unsafe) static var description: IntentDescription = "Opens Kartonche and navigates to a specific loyalty card"
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    @Parameter(title: "Card")
    var card: CardAppEntity

    @MainActor
    func perform() async throws -> some IntentResult {
        let urlString = "kartonche://card?id=\(card.id.uuidString)"
        if let url = URL(string: urlString) {
            NotificationCenter.default.post(
                name: .controlIntentDeepLink,
                object: nil,
                userInfo: ["url": url]
            )
        }
        return .result()
    }
}

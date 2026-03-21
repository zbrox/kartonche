//
//  AppShortcuts.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents

struct KartoncheShortcuts: AppShortcutsProvider {
    static var appShortcuts: [AppShortcut] {
        AppShortcut(
            intent: ShowCardIntent(),
            phrases: [
                "Show my \(\.$card) in \(.applicationName)",
                "Open \(\.$card) in \(.applicationName)",
            ],
            shortTitle: "Show Card",
            systemImageName: "creditcard"
        )

        AppShortcut(
            intent: GetCardBarcodeIntent(),
            phrases: [
                "Get barcode for \(\.$card) from \(.applicationName)",
            ],
            shortTitle: "Get Card Barcode",
            systemImageName: "barcode"
        )

        AppShortcut(
            intent: SearchCardsIntent(),
            phrases: [
                "Search cards in \(.applicationName)",
                "Find cards in \(.applicationName)",
            ],
            shortTitle: "Search Cards",
            systemImageName: "magnifyingglass"
        )

        AppShortcut(
            intent: GenerateBarcodeIntent(),
            phrases: [
                "Generate \(\.$barcodeType) barcode with \(.applicationName)",
            ],
            shortTitle: "Generate Barcode",
            systemImageName: "qrcode"
        )
    }
}

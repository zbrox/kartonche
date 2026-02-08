//
//  OpenFavoriteCardControl.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-08.
//

import AppIntents
import SwiftUI
import WidgetKit

@available(iOS 18.0, *)
struct OpenFavoriteCardControl: ControlWidget {
    var body: some ControlWidgetConfiguration {
        AppIntentControlConfiguration(
            kind: "com.zbrox.kartonche.openFavoriteCard",
            provider: FavoriteCardControlProvider()
        ) { configuration in
            ControlWidgetButton(action: OpenFavoriteCardIntent(cardEntity: configuration.selectedCard)) {
                if let card = configuration.selectedCard {
                    Label(card.name, systemImage: "star.fill")
                } else {
                    Label("Choose Card", systemImage: "star")
                }
            }
        }
        .displayName("Open Favorite Card")
        .description("Opens your selected favorite loyalty card")
    }
}

@available(iOS 18.0, *)
extension OpenFavoriteCardControl {
    struct FavoriteCardControlProvider: AppIntentControlValueProvider {
        func previewValue(configuration: FavoriteCardControlConfiguration) -> FavoriteCardControlConfiguration {
            return configuration
        }
        
        func currentValue(configuration: FavoriteCardControlConfiguration) async throws -> FavoriteCardControlConfiguration {
            // Return the configuration as-is
            // The card selection is already stored in the configuration
            return configuration
        }
    }
}

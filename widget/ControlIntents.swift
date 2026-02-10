//
//  ControlIntents.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-08.
//

import AppIntents
import Foundation
import CoreLocation

extension Notification.Name {
    /// Posted by control widget intents to navigate to a deep link URL.
    /// OpenURLIntent doesn't deliver URLs back to the app when the intent
    /// runs in-process, so we use NotificationCenter instead.
    static let controlIntentDeepLink = Notification.Name("controlIntentDeepLink")
}

// MARK: - Open Favorite Card Intent

struct OpenFavoriteCardIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Open Favorite Card"
    nonisolated(unsafe) static var description: IntentDescription = "Opens your selected favorite loyalty card"
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    @Parameter(title: "Card")
    var cardEntity: CardEntity?

    init() {}

    init(cardEntity: CardEntity?) {
        self.cardEntity = cardEntity
    }

    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        if let cardEntity = cardEntity {
            let urlString = "kartonche://card?id=\(cardEntity.id.uuidString)"
            if let url = URL(string: urlString) {
                NotificationCenter.default.post(
                    name: .controlIntentDeepLink,
                    object: nil,
                    userInfo: ["url": url]
                )
                return .result(opensIntent: OpenURLIntent(url))
            }
        }

        // No card configured - show configuration prompt by returning needsValueError
        throw $cardEntity.needsValueError()
    }
}

// MARK: - Open Nearest Store Card Intent

struct OpenNearestCardIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Open Nearest Store Card"
    nonisolated(unsafe) static var description: IntentDescription = "Opens the loyalty card for the nearest store"
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult & OpensIntent {
        let allCards = SharedDataManager.fetchAllCards()
        var nearestCard: (card: LoyaltyCard, distance: Double)?

        if let (latitude, longitude) = SharedDataManager.getLastKnownLocation() {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)

            for card in allCards {
                for location in card.locations {
                    let cardLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    let distance = userLocation.distance(from: cardLocation)

                    if distance <= 1000.0 {
                        if nearestCard == nil || distance < nearestCard!.distance {
                            nearestCard = (card, distance)
                        }
                    }
                }
            }
        }

        let urlString: String
        if let card = nearestCard?.card {
            urlString = "kartonche://card?id=\(card.id.uuidString)"
        } else {
            urlString = "kartonche://"
        }

        let url = URL(string: urlString)!
        NotificationCenter.default.post(
            name: .controlIntentDeepLink,
            object: nil,
            userInfo: ["url": url]
        )
        return .result(opensIntent: OpenURLIntent(url))
    }
}

// MARK: - Launch App Intent

struct LaunchAppIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Launch Kartonche"
    nonisolated(unsafe) static var description: IntentDescription = "Opens the Kartonche app"
    nonisolated(unsafe) static var openAppWhenRun: Bool = true

    @MainActor
    func perform() async throws -> some IntentResult {
        return .result()
    }
}

// MARK: - Favorite Card Control Configuration

struct FavoriteCardControlConfiguration: ControlConfigurationIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Select Favorite Card"
    nonisolated(unsafe) static var description: IntentDescription = "Choose which loyalty card to open"

    @Parameter(title: "Card")
    var selectedCard: CardEntity?
}

//
//  ControlIntents.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-08.
//

import AppIntents
import Foundation
import CoreLocation

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
        // If card is configured, open it
        if let cardEntity = cardEntity {
            let urlString = "kartonche://card?id=\(cardEntity.id.uuidString)"
            if let url = URL(string: urlString) {
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
        // Get current location
        let locationManager = CLLocationManager()
        
        guard let userLocation = locationManager.location else {
            // No location available - open app to card list
            let url = URL(string: "kartonche://")!
            return .result(opensIntent: OpenURLIntent(url))
        }
        
        // Find card for nearest store within 1km
        let allCards = SharedDataManager.fetchAllCards()
        var nearestCard: (card: LoyaltyCard, distance: Double)?
        
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
        
        // Open card for nearest store or fallback to app
        let urlString: String
        if let card = nearestCard?.card {
            urlString = "kartonche://card?id=\(card.id.uuidString)"
        } else {
            // No cards within 1km - open app to card list
            urlString = "kartonche://"
        }
        
        let url = URL(string: urlString)!
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

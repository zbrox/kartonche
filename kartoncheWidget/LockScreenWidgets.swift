//
//  LockScreenWidgets.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-07.
//

import WidgetKit
import SwiftUI
import CoreLocation

// MARK: - Circular Lock Screen Widget

struct CircularLockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> CircularLockScreenEntry {
        CircularLockScreenEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (CircularLockScreenEntry) -> ()) {
        let entry = CircularLockScreenEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<CircularLockScreenEntry>) -> ()) {
        let entry = CircularLockScreenEntry(date: Date())
        
        // Refresh every day
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct CircularLockScreenEntry: TimelineEntry {
    let date: Date
}

struct CircularLockScreenWidgetEntryView : View {
    var entry: CircularLockScreenEntry
    
    var body: some View {
        ZStack {
            Circle()
                .fill(Color.blue)
            
            Image(systemName: "creditcard.fill")
                .font(.system(size: 24))
                .foregroundColor(.white)
        }
    }
}

struct CircularLockScreenWidget: Widget {
    let kind: String = "CircularLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CircularLockScreenProvider()) { entry in
            CircularLockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Kartonche")
        .description("Quick access to your loyalty cards")
        .supportedFamilies([.accessoryCircular])
    }
}

// MARK: - Rectangular Lock Screen Widget

struct RectangularLockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> RectangularLockScreenEntry {
        RectangularLockScreenEntry(date: Date(), card: nil, distance: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (RectangularLockScreenEntry) -> ()) {
        let entry = RectangularLockScreenEntry(date: Date(), card: nil, distance: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<RectangularLockScreenEntry>) -> ()) {
        let currentDate = Date()
        
        // Get current location
        let locationManager = CLLocationManager()
        let authStatus = locationManager.authorizationStatus
        
        var card: LoyaltyCard?
        var distance: Double?
        
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways,
           let userLocation = locationManager.location {
            // Find nearest card within 1km
            let allCards = SharedDataManager.fetchAllCards()
            var nearestCard: (card: LoyaltyCard, distance: Double)?
            
            for loyaltyCard in allCards {
                for location in loyaltyCard.locations {
                    let cardLocation = CLLocation(latitude: location.latitude, longitude: location.longitude)
                    let dist = userLocation.distance(from: cardLocation)
                    
                    if dist <= 1000.0 { // Within 1km
                        if nearestCard == nil || dist < nearestCard!.distance {
                            nearestCard = (loyaltyCard, dist)
                        }
                    }
                }
            }
            
            card = nearestCard?.card
            distance = nearestCard?.distance
        }
        
        // Fallback: Show first favorite with locations if no nearby card
        if card == nil {
            let allCards = SharedDataManager.fetchAllCards()
            card = allCards.first(where: { $0.isFavorite && !$0.locations.isEmpty })
        }
        
        let entry = RectangularLockScreenEntry(date: currentDate, card: card, distance: distance)
        
        // Refresh every 15 minutes to update location
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct RectangularLockScreenEntry: TimelineEntry {
    let date: Date
    let card: LoyaltyCard?
    let distance: Double?
}

struct RectangularLockScreenWidgetEntryView : View {
    var entry: RectangularLockScreenEntry
    
    var body: some View {
        if let card = entry.card {
            HStack(spacing: 4) {
                Image(systemName: "creditcard.fill")
                    .font(.system(size: 14))
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(card.name)
                        .font(.system(size: 14, weight: .semibold))
                        .lineLimit(1)
                    
                    if let distance = entry.distance {
                        Text(distanceText(distance))
                            .font(.system(size: 12))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
            }
            .widgetURL(createDeepLink(for: card))
        } else {
            HStack(spacing: 4) {
                Image(systemName: "creditcard")
                    .font(.system(size: 14))
                
                Text("No nearby cards")
                    .font(.system(size: 12))
                    .foregroundColor(.secondary)
            }
        }
    }
    
    private func distanceText(_ distance: Double) -> String {
        if distance < 1000 {
            return String(format: "%.0fm", distance)
        } else {
            return String(format: "%.1fkm", distance / 1000.0)
        }
    }
    
    private func createDeepLink(for card: LoyaltyCard) -> URL? {
        var components = URLComponents()
        components.scheme = "kartonche"
        components.host = "card"
        components.queryItems = [URLQueryItem(name: "id", value: card.id.uuidString)]
        return components.url
    }
}

struct RectangularLockScreenWidget: Widget {
    let kind: String = "RectangularLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: RectangularLockScreenProvider()) { entry in
            RectangularLockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nearest Card")
        .description("Shows your closest loyalty card")
        .supportedFamilies([.accessoryRectangular])
    }
}

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
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct CircularLockScreenWidget: Widget {
    let kind: String = "CircularLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: CircularLockScreenProvider()) { entry in
            CircularLockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "Kartonche", comment: "Lock screen circular widget name"))
        .description(String(localized: "Quick access to your loyalty cards", comment: "Lock screen circular widget description"))
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
            // Find card for nearest store within 1km
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
        
        // Fallback: Show first favorite with locations if no nearby store
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
        Group {
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
                    
                    Text(String(localized: "No nearby stores", comment: "Lock screen rectangular widget message when no stores within 1km"))
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                }
            }
        }
        .containerBackground(for: .widget) {
            Color.clear
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
        .configurationDisplayName(String(localized: "Nearest Store", comment: "Lock screen rectangular widget name"))
        .description(String(localized: "Shows card for nearest store", comment: "Lock screen rectangular widget description"))
        .supportedFamilies([.accessoryRectangular])
    }
}

// MARK: - Inline Lock Screen Widget (Bottom positions)

struct InlineLockScreenProvider: TimelineProvider {
    func placeholder(in context: Context) -> InlineLockScreenEntry {
        InlineLockScreenEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (InlineLockScreenEntry) -> ()) {
        let entry = InlineLockScreenEntry(date: Date())
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<InlineLockScreenEntry>) -> ()) {
        let entry = InlineLockScreenEntry(date: Date())
        
        // Refresh once per day
        let nextUpdate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct InlineLockScreenEntry: TimelineEntry {
    let date: Date
}

struct InlineLockScreenWidgetEntryView : View {
    var entry: InlineLockScreenEntry
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "creditcard.fill")
            Text(String(localized: "Kartonche", comment: "Lock screen inline widget app name"))
        }
        .widgetURL(URL(string: "kartonche://")!)
        .containerBackground(for: .widget) {
            Color.clear
        }
    }
}

struct InlineLockScreenWidget: Widget {
    let kind: String = "InlineLockScreenWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: InlineLockScreenProvider()) { entry in
            InlineLockScreenWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "Open Kartonche", comment: "Lock screen inline widget name"))
        .description(String(localized: "Quick access to open the app", comment: "Lock screen inline widget description"))
        .supportedFamilies([.accessoryInline])
    }
}

//
//  NearestLocationWidget.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-07.
//

import WidgetKit
import SwiftUI
import CoreLocation

struct NearestLocationProvider: TimelineProvider {
    func placeholder(in context: Context) -> NearestLocationEntry {
        NearestLocationEntry(date: Date(), card: nil, distance: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (NearestLocationEntry) -> ()) {
        let entry = NearestLocationEntry(date: Date(), card: nil, distance: nil)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<NearestLocationEntry>) -> ()) {
        let currentDate = Date()
        let allCards = SharedDataManager.fetchAllCards()
        
        var card: LoyaltyCard?
        var distance: Double?
        
        // Try to get last known location from shared storage
        if let (latitude, longitude) = SharedDataManager.getLastKnownLocation() {
            let userLocation = CLLocation(latitude: latitude, longitude: longitude)
            
            // Find nearest card within 1km
            var nearestCard: (card: LoyaltyCard, distance: Double)?
            
            for loyaltyCard in allCards where !loyaltyCard.locations.isEmpty {
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
        
        // Fallback 1: Show first favorite with locations if no nearby card
        if card == nil {
            card = allCards.first(where: { $0.isFavorite && !$0.locations.isEmpty })
        }
        
        // Fallback 2: Show any card with locations
        if card == nil {
            card = allCards.first(where: { !$0.locations.isEmpty })
        }
        
        let entry = NearestLocationEntry(date: currentDate, card: card, distance: distance)
        
        // Refresh every 15 minutes to update location
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct NearestLocationEntry: TimelineEntry {
    let date: Date
    let card: LoyaltyCard?
    let distance: Double?
}

struct NearestLocationWidgetEntryView : View {
    var entry: NearestLocationEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let card = entry.card {
            NearestCardView(card: card, distance: entry.distance, family: family)
                .widgetURL(createDeepLink(for: card))
        } else {
            NearestPlaceholderView(family: family, message: "No nearby cards")
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

struct NearestCardView: View {
    let card: LoyaltyCard
    let distance: Double?
    let family: WidgetFamily
    
    var primaryColor: Color {
        if let colorHex = card.color {
            return Color(hex: colorHex) ?? .blue
        }
        return .blue
    }
    
    var headerBackground: some View {
        primaryColor
    }
    
    var isSquareBarcode: Bool {
        card.barcodeType == .qr || card.barcodeType == .aztec
    }
    
    var distanceText: String? {
        guard let distance = distance else { return nil }
        
        if distance < 1000 {
            return String(format: "%.0fm", distance)
        } else {
            return String(format: "%.1fkm", distance / 1000.0)
        }
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with card name and distance
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(card.name)
                        .font(.headline)
                        .foregroundColor(primaryColor.contrastingTextColor)
                        .lineLimit(1)
                    
                    if family != .systemSmall {
                        Text(card.storeName)
                            .font(.caption)
                            .foregroundColor(primaryColor.contrastingTextColor.opacity(0.8))
                            .lineLimit(1)
                    }
                }
                
                Spacer()
                
                if let distText = distanceText {
                    HStack(spacing: 2) {
                        Image(systemName: "location.fill")
                            .font(.caption2)
                        Text(distText)
                            .font(.caption)
                            .bold()
                    }
                    .foregroundColor(primaryColor.contrastingTextColor)
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, family == .systemSmall ? 8 : 6)
            .background(headerBackground)
            
            // Barcode
            if family != .systemSmall {
                if let barcodeImage = generateBarcodeImage() {
                    if isSquareBarcode {
                        // QR codes - fill space
                        Spacer(minLength: 0)
                        Image(uiImage: barcodeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                        Spacer(minLength: 0)
                    } else {
                        // Linear barcodes - fill available space
                        Image(uiImage: barcodeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
            } else {
                // Small widget - show QR or empty
                if let barcodeImage = generateBarcodeImage(), isSquareBarcode {
                    Spacer(minLength: 0)
                    Image(uiImage: barcodeImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .padding(8)
                    Spacer(minLength: 0)
                } else {
                    Spacer()
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
    
    private func generateBarcodeImage() -> UIImage? {
        let result = BarcodeGenerator.generate(
            from: card.barcodeData,
            type: card.barcodeType,
            scale: 5.0
        )
        
        switch result {
        case .success(let image):
            return image
        case .failure:
            return nil
        }
    }
}

struct NearestPlaceholderView: View {
    let family: WidgetFamily
    let message: String
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "location.slash")
                .font(.system(size: family == .systemSmall ? 30 : 40))
                .foregroundColor(.secondary)
            
            if family != .systemSmall {
                Text(message)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct NearestLocationWidget: Widget {
    let kind: String = "NearestLocationWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: NearestLocationProvider()) { entry in
            NearestLocationWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Nearest Card")
        .description("Shows your closest loyalty card within 1km")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

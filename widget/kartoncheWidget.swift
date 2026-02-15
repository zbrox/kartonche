//
//  kartoncheWidget.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import WidgetKit
import SwiftUI

struct Provider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> CardEntry {
        CardEntry(date: Date(), card: nil)
    }

    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> CardEntry {
        if let cardEntity = configuration.card,
           let card = SharedDataManager.fetchCard(id: cardEntity.id) {
            return CardEntry(date: Date(), card: card)
        }
        return CardEntry(date: Date(), card: nil)
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<CardEntry> {
        var card: LoyaltyCard?
        
        if let cardEntity = configuration.card {
            card = SharedDataManager.fetchCard(id: cardEntity.id)
        }
        
        let entry = CardEntry(date: Date(), card: card)
        
        // Refresh timeline every hour to update "last used" and expiration status
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date()) ?? Date()
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
}

struct CardEntry: TimelineEntry {
    let date: Date
    let card: LoyaltyCard?
}

struct IndividualCardWidgetEntryView : View {
    var entry: CardEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let card = entry.card {
            CardWidgetView(card: card, family: family)
                .widgetURL(createDeepLink(for: card))
        } else {
            PlaceholderView(family: family)
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

struct CardWidgetView: View {
    let card: LoyaltyCard
    let family: WidgetFamily
    
    var primaryColor: Color {
        if let colorHex = card.color {
            return Color(hex: colorHex) ?? .blue
        }
        return .blue
    }
    
    var headerBackground: some View {
        Group {
            if let secondaryColorHex = card.secondaryColor,
               let secondaryColor = Color(hex: secondaryColorHex),
               secondaryColor != primaryColor {
                // Use a subtle gradient if secondary color exists and is different
                LinearGradient(
                    colors: [primaryColor, primaryColor.opacity(0.8)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            } else {
                // Use solid color if no secondary or if same as primary
                primaryColor
            }
        }
    }
    
    var isSquareBarcode: Bool {
        card.barcodeType == .qr || card.barcodeType == .aztec
    }
    
    var barcodeMaxWidth: CGFloat? {
        if isSquareBarcode {
            // Square codes - even bigger
            return family == .systemMedium ? 130 : 200
        } else {
            // Linear barcodes can use full width
            return nil
        }
    }
    
    var barcodeMaxHeight: CGFloat? {
        if isSquareBarcode {
            // Square codes - even bigger
            return family == .systemMedium ? 130 : 200
        } else {
            // Linear barcodes - much taller for better scanning
            return family == .systemMedium ? 120 : 140
        }
    }
    
    var barcodePaddingHorizontal: CGFloat {
        if isSquareBarcode {
            // Square codes need less horizontal padding
            return 4
        } else {
            // Linear barcodes need more padding
            return 8
        }
    }
    
    var body: some View {
        Group {
            if family == .systemMedium && isSquareBarcode {
                // Horizontal layout for square barcodes on medium widgets
                HStack(spacing: 0) {
                    // Left side: Card info with colored background
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.name)
                            .font(.headline)
                            .foregroundColor(primaryColor.contrastingTextColor)
                            .lineLimit(2)

                        if let storeName = card.storeName, !storeName.isEmpty {
                            Text(storeName)
                                .font(.caption)
                                .foregroundColor(primaryColor.contrastingTextColor.opacity(0.8))
                                .lineLimit(2)
                        }

                        Spacer()
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .background(headerBackground)
                    
                    // Right side: QR code
                    if let barcodeImage = generateBarcodeImage() {
                        Image(uiImage: barcodeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .padding(8)
                    }
                }
            } else {
                // Vertical layout for all other cases
                VStack(spacing: 0) {
                    // Header with card name and store
                    if family == .systemSmall {
                        // Compact header for ALL small widgets - just card name
                        Text(card.name)
                            .font(.headline)
                            .foregroundColor(primaryColor.contrastingTextColor)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(8)
                            .background(headerBackground)
                    } else if family == .systemMedium && !isSquareBarcode {
                        // Compact header for medium widgets with linear barcodes - minimal padding
                        Text(card.name)
                            .font(.headline)
                            .foregroundColor(primaryColor.contrastingTextColor)
                            .lineLimit(1)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(headerBackground)
                    } else {
                        // Full header for large widgets and medium with QR codes
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.name)
                                .font(.headline)
                                .foregroundColor(primaryColor.contrastingTextColor)
                                .lineLimit(1)

                            if let storeName = card.storeName, !storeName.isEmpty {
                                Text(storeName)
                                    .font(.caption)
                                    .foregroundColor(primaryColor.contrastingTextColor.opacity(0.8))
                                    .lineLimit(1)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(8)
                        .background(headerBackground)
                    }
                    
                    // Barcode
                    if family != .systemSmall {
                        if let barcodeImage = generateBarcodeImage() {
                            if isSquareBarcode {
                                // Square codes on large widgets
                                Spacer(minLength: 0)
                                Image(uiImage: barcodeImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(width: barcodeMaxWidth ?? 130, height: barcodeMaxHeight ?? 130)
                                    .padding(.horizontal, barcodePaddingHorizontal)
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
                        // Small widget
                        if let barcodeImage = generateBarcodeImage() {
                            if isSquareBarcode {
                                // Show QR code for square barcodes
                                Spacer(minLength: 0)
                                Image(uiImage: barcodeImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .padding(8)
                                Spacer(minLength: 0)
                            } else {
                                // Linear barcodes: just show empty space (header already shows card info)
                                Spacer()
                            }
                        } else {
                            // Fallback: empty space if barcode generation fails
                            Spacer()
                        }
                    }
                    

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
    
    private func getInitials(from text: String) -> String {
        let words = text.split(separator: " ")
        if words.count >= 2 {
            let firstInitial = words[0].first.map(String.init) ?? ""
            let secondInitial = words[1].first.map(String.init) ?? ""
            return (firstInitial + secondInitial).uppercased()
        } else if let firstWord = words.first {
            return String(firstWord.prefix(2)).uppercased()
        }
        return "??"
    }
}

struct PlaceholderView: View {
    let family: WidgetFamily
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "creditcard")
                .font(.system(size: family == .systemSmall ? 30 : 40))
                .foregroundColor(.secondary)
            
            if family != .systemSmall {
                Text(String(localized: "No Card Selected", comment: "Individual card widget empty state message"))
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

struct kartoncheWidget: Widget {
    let kind: String = "kartoncheWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(kind: kind, intent: ConfigurationAppIntent.self, provider: Provider()) { entry in
            IndividualCardWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "Loyalty Card", comment: "Home screen widget name"))
        .description(String(localized: "Display a specific loyalty card with scannable barcode", comment: "Home screen widget description"))
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    kartoncheWidget()
} timeline: {
    CardEntry(date: .now, card: nil)
}

//
//  FavoritesCarouselWidget.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-07.
//

import WidgetKit
import SwiftUI
import AppIntents

// App Intents for navigation
struct NavigateToNextCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Next Card"
    static var description: IntentDescription = "Show the next favorite card"
    
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.zbrox.kartonche")
        let currentIndex = defaults?.integer(forKey: "carouselIndex") ?? 0
        
        // Get total favorites count
        let favorites = SharedDataManager.fetchAllCards().filter { $0.isFavorite }
        let newIndex = favorites.isEmpty ? 0 : (currentIndex + 1) % favorites.count
        
        defaults?.set(newIndex, forKey: "carouselIndex")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct NavigateToPreviousCardIntent: AppIntent {
    static var title: LocalizedStringResource = "Previous Card"
    static var description: IntentDescription = "Show the previous favorite card"
    
    func perform() async throws -> some IntentResult {
        let defaults = UserDefaults(suiteName: "group.com.zbrox.kartonche")
        let currentIndex = defaults?.integer(forKey: "carouselIndex") ?? 0
        
        // Get total favorites count
        let favorites = SharedDataManager.fetchAllCards().filter { $0.isFavorite }
        let newIndex = favorites.isEmpty ? 0 : (currentIndex > 0 ? currentIndex - 1 : favorites.count - 1)
        
        defaults?.set(newIndex, forKey: "carouselIndex")
        WidgetCenter.shared.reloadAllTimelines()
        return .result()
    }
}

struct FavoritesCarouselProvider: TimelineProvider {
    func placeholder(in context: Context) -> FavoritesCarouselEntry {
        FavoritesCarouselEntry(date: Date(), favoriteCards: [], currentIndex: 0)
    }

    func getSnapshot(in context: Context, completion: @escaping (FavoritesCarouselEntry) -> ()) {
        let favorites = SharedDataManager.fetchAllCards().filter { $0.isFavorite }
        let entry = FavoritesCarouselEntry(date: Date(), favoriteCards: favorites, currentIndex: 0)
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<FavoritesCarouselEntry>) -> ()) {
        let currentDate = Date()
        let favorites = SharedDataManager.fetchAllCards().filter { $0.isFavorite }
        
        // Get stored index from UserDefaults
        let currentIndex = UserDefaults(suiteName: "group.com.zbrox.kartonche")?.integer(forKey: "carouselIndex") ?? 0
        let validIndex = favorites.isEmpty ? 0 : min(currentIndex, favorites.count - 1)
        
        let entry = FavoritesCarouselEntry(date: currentDate, favoriteCards: favorites, currentIndex: validIndex)
        
        // Refresh every hour
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

struct FavoritesCarouselEntry: TimelineEntry {
    let date: Date
    let favoriteCards: [LoyaltyCard]
    let currentIndex: Int
    
    var currentCard: LoyaltyCard? {
        guard !favoriteCards.isEmpty, currentIndex < favoriteCards.count else {
            return nil
        }
        return favoriteCards[currentIndex]
    }
}

struct FavoritesCarouselWidgetEntryView : View {
    var entry: FavoritesCarouselEntry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        if let card = entry.currentCard {
            CarouselCardView(
                card: card,
                currentIndex: entry.currentIndex,
                totalCards: entry.favoriteCards.count,
                family: family
            )
        } else {
            CarouselPlaceholderView()
        }
    }
}

struct CarouselCardView: View {
    let card: LoyaltyCard
    let currentIndex: Int
    let totalCards: Int
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
    
    var body: some View {
        Group {
            if isSquareBarcode {
                // Horizontal layout for QR codes - like Individual Card Widget
                HStack(spacing: 0) {
                    // Left side: Card info with colored background and navigation
                    VStack(alignment: .leading, spacing: 4) {
                        Text(card.name)
                            .font(.headline)
                            .foregroundColor(primaryColor.contrastingTextColor)
                            .lineLimit(2)
                        
                        // Page indicator
                        if totalCards > 1 {
                            Text("\(currentIndex + 1) / \(totalCards)")
                                .font(.caption2)
                                .foregroundColor(primaryColor.contrastingTextColor.opacity(0.7))
                        }
                        
                        Spacer()
                        
                        // Navigation buttons (vertical)
                        HStack(spacing: 12) {
                            Button(intent: NavigateToPreviousCardIntent()) {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(primaryColor.contrastingTextColor)
                                    .frame(width: 28, height: 28)
                                    .background(primaryColor.contrastingTextColor.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .disabled(totalCards <= 1)
                            .opacity(totalCards <= 1 ? 0.3 : 1.0)
                            
                            Button(intent: NavigateToNextCardIntent()) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(primaryColor.contrastingTextColor)
                                    .frame(width: 28, height: 28)
                                    .background(primaryColor.contrastingTextColor.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .disabled(totalCards <= 1)
                            .opacity(totalCards <= 1 ? 0.3 : 1.0)
                        }
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
                // Vertical layout for linear barcodes - they need width
                VStack(spacing: 0) {
                    // Compact header with card name and navigation buttons
                    HStack(spacing: 8) {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(card.name)
                                .font(.headline)
                                .foregroundColor(primaryColor.contrastingTextColor)
                                .lineLimit(1)
                            
                            // Page indicator
                            if totalCards > 1 {
                                Text("\(currentIndex + 1) / \(totalCards)")
                                    .font(.caption2)
                                    .foregroundColor(primaryColor.contrastingTextColor.opacity(0.7))
                            }
                        }
                        
                        Spacer()
                        
                        // Navigation buttons
                        HStack(spacing: 8) {
                            Button(intent: NavigateToPreviousCardIntent()) {
                                Image(systemName: "chevron.up")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(primaryColor.contrastingTextColor)
                                    .frame(width: 28, height: 28)
                                    .background(primaryColor.contrastingTextColor.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .disabled(totalCards <= 1)
                            .opacity(totalCards <= 1 ? 0.3 : 1.0)
                            
                            Button(intent: NavigateToNextCardIntent()) {
                                Image(systemName: "chevron.down")
                                    .font(.system(size: 12, weight: .semibold))
                                    .foregroundColor(primaryColor.contrastingTextColor)
                                    .frame(width: 28, height: 28)
                                    .background(primaryColor.contrastingTextColor.opacity(0.2))
                                    .clipShape(Circle())
                            }
                            .buttonStyle(.plain)
                            .disabled(totalCards <= 1)
                            .opacity(totalCards <= 1 ? 0.3 : 1.0)
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(headerBackground)
                    
                    // Linear barcode - fill available space
                    if let barcodeImage = generateBarcodeImage() {
                        Image(uiImage: barcodeImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                    }
                }
            }
        }
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
        .widgetURL(createDeepLink(for: card))
        .onAppear {
            // Store current index for next reload
            UserDefaults(suiteName: "group.com.zbrox.kartonche")?.set(currentIndex, forKey: "carouselIndex")
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
    
    private func createDeepLink(for card: LoyaltyCard) -> URL? {
        var components = URLComponents()
        components.scheme = "kartonche"
        components.host = "card"
        components.queryItems = [URLQueryItem(name: "id", value: card.id.uuidString)]
        return components.url
    }
    
    private func navigateToPrevious() {
        let newIndex = currentIndex > 0 ? currentIndex - 1 : totalCards - 1
        UserDefaults(suiteName: "group.com.zbrox.kartonche")?.set(newIndex, forKey: "carouselIndex")
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func navigateToNext() {
        let newIndex = currentIndex < totalCards - 1 ? currentIndex + 1 : 0
        UserDefaults(suiteName: "group.com.zbrox.kartonche")?.set(newIndex, forKey: "carouselIndex")
        WidgetCenter.shared.reloadAllTimelines()
    }
}

struct CarouselPlaceholderView: View {
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: "star.slash")
                .font(.system(size: 40))
                .foregroundColor(.secondary)
            
            Text(String(localized: "No Favorites", comment: "Favorites carousel widget empty state title"))
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Text(String(localized: "Mark cards as favorites to see them here", comment: "Favorites carousel widget empty state message"))
                .font(.caption2)
                .foregroundColor(.secondary.opacity(0.8))
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget) {
            Color(UIColor.systemBackground)
        }
    }
}

struct FavoritesCarouselWidget: Widget {
    let kind: String = "FavoritesCarouselWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: FavoritesCarouselProvider()) { entry in
            FavoritesCarouselWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(String(localized: "Favorites Carousel", comment: "Home screen widget name"))
        .description(String(localized: "Navigate through your favorite cards with arrow buttons", comment: "Home screen widget description"))
        .supportedFamilies([.systemMedium])
    }
}

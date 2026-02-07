//
//  CardListView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import SwiftData
import CoreLocation
import WidgetKit
import UniformTypeIdentifiers

struct PendingCard: Identifiable {
    let id = UUID()
    let merchant: MerchantTemplate
    let program: ProgramTemplate?
}

struct CardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Query private var allCards: [LoyaltyCard]
    
    @State private var searchText = ""
    @State private var sortOption: SortOption = .alphabetical
    @AppStorage("showExpiredCards") private var showExpiredCards = true
    @State private var showingMerchantSelection = false
    @State private var merchantForProgramSelection: MerchantTemplate?
    @State private var pendingCard: PendingCard?
    @State private var selectedCard: LoyaltyCard?
    @State private var navigationPath = NavigationPath()
    @State private var showingSettings = false
    @State private var showingAlwaysPrompt = false
    @State private var showAlwaysBanner = false
    @State private var shareItem: ShareItem?
    @State private var importContainer: CardExportContainer?
    @State private var showingImportPreview = false
    
    struct ShareItem: Identifiable {
        let id = UUID()
        let url: URL
    }
    @StateObject private var locationManager = LocationManager()
    
    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case recent = "Recent"
        case favorites = "Favorites"
        case expiring = "Expiring Soon"
        
        var localizedName: String {
            String(localized: String.LocalizationValue(rawValue))
        }
    }
    
    private var nearbyCards: [(card: LoyaltyCard, distance: Double)] {
        guard locationManager.authorizationStatus == .authorizedWhenInUse ||
              locationManager.authorizationStatus == .authorizedAlways else {
            return []
        }
        var nearby = locationManager.cardsNearby(allCards, radius: 1000.0)
        
        // Filter expired cards if toggle is off
        if !showExpiredCards {
            nearby = nearby.filter { !$0.card.isExpired }
        }
        
        return nearby
    }
    
    private var filteredAndSortedCards: [LoyaltyCard] {
        var cards = allCards
        
        // Filter by search
        if !searchText.isEmpty {
            cards = cards.filter { card in
                card.name.localizedCaseInsensitiveContains(searchText) ||
                card.storeName.localizedCaseInsensitiveContains(searchText) ||
                card.cardNumber.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        // Filter expired cards
        if !showExpiredCards {
            cards = cards.filter { !$0.isExpired }
        }
        
        // Sort
        switch sortOption {
        case .alphabetical:
            cards.sort { $0.name.localizedCompare($1.name) == .orderedAscending }
        case .recent:
            cards.sort { ($0.lastUsedDate ?? .distantPast) > ($1.lastUsedDate ?? .distantPast) }
        case .favorites:
            cards.sort { card1, card2 in
                if card1.isFavorite == card2.isFavorite {
                    return card1.name.localizedCompare(card2.name) == .orderedAscending
                }
                return card1.isFavorite && !card2.isFavorite
            }
        case .expiring:
            cards.sort { card1, card2 in
                // Cards with expiration dates first
                let date1 = card1.expirationDate ?? .distantFuture
                let date2 = card2.expirationDate ?? .distantFuture
                return date1 < date2
            }
        }
        
        return cards
    }
    
    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack(spacing: 0) {
                // Info banner for Always permission
                if showAlwaysBanner {
                    alwaysPermissionBanner
                }
                
                Group {
                    if filteredAndSortedCards.isEmpty {
                        emptyStateView
                    } else {
                        cardListView
                    }
                }
            }
            .navigationTitle(String(localized: "Loyalty Cards"))
            .navigationDestination(for: LoyaltyCard.self) { card in
                CardDisplayView(card: card)
                    .navigationBarHidden(true)
            }
            .onOpenURL { url in
                handleOpenURL(url)
            }
            .searchable(text: $searchText, prompt: String(localized: "Search"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    sortMenu
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingMerchantSelection) {
                MerchantSelectionView(isPresented: $showingMerchantSelection) { merchant, program in
                    if merchant.programs.count > 1 {
                        merchantForProgramSelection = merchant
                        showingMerchantSelection = false
                    } else {
                        pendingCard = PendingCard(merchant: merchant, program: program)
                        showingMerchantSelection = false
                    }
                }
            }
            .sheet(item: $merchantForProgramSelection) { merchant in
                ProgramSelectionView(
                    merchant: merchant,
                    isPresented: Binding(
                        get: { merchantForProgramSelection != nil },
                        set: { newValue in
                            if !newValue {
                                merchantForProgramSelection = nil
                            }
                        }
                    )
                ) { program in
                    pendingCard = PendingCard(merchant: merchant, program: program)
                    merchantForProgramSelection = nil
                }
            }
            .sheet(item: $pendingCard) { pending in
                CardEditorView(merchantTemplate: pending.merchant, program: pending.program)
            }
            .sheet(item: $selectedCard) { card in
                CardEditorView(card: card)
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(isPresented: $showingAlwaysPrompt) {
                AlwaysLocationExplanationView(locationManager: locationManager)
            }
            .sheet(item: $shareItem) { item in
                ActivityViewController(activityItems: [item.url])
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showingImportPreview) {
                if let container = importContainer {
                    ImportPreviewView(
                        container: container,
                        existingCards: allCards,
                        onImport: { strategy in
                            try await importCards(container: container, strategy: strategy)
                        },
                        onCancel: {
                            showingImportPreview = false
                            importContainer = nil
                        }
                    )
                }
            }
        }
    }
    
    private var cardListView: some View {
        List {
            // Nearby Cards section
            if !nearbyCards.isEmpty && searchText.isEmpty {
                Section {
                    ForEach(nearbyCards, id: \.card.id) { nearby in
                        NavigationLink(value: nearby.card) {
                            CardRowView(card: nearby.card, distance: nearby.distance) {
                                toggleFavorite(nearby.card)
                            }
                        }
                        .contextMenu {
                            Button {
                                shareCard(nearby.card)
                            } label: {
                                Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                            }
                            
                            Button {
                                selectedCard = nearby.card
                            } label: {
                                Label(String(localized: "Edit"), systemImage: "pencil")
                            }
                            
                            Button(role: .destructive) {
                                deleteCard(nearby.card)
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                        }
                    }
                } header: {
                    Label(String(localized: "Nearby"), systemImage: "location.fill")
                }
            }
            
            // All Cards section
            Section {
                ForEach(filteredAndSortedCards) { card in
                    NavigationLink(value: card) {
                        CardRowView(card: card) {
                            toggleFavorite(card)
                        }
                    }
                    .contextMenu {
                        Button {
                            shareCard(card)
                        } label: {
                            Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                        }
                        
                        Button {
                            selectedCard = card
                        } label: {
                            Label(String(localized: "Edit"), systemImage: "pencil")
                        }
                        
                        Button(role: .destructive) {
                            deleteCard(card)
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                    }
                    .accessibilityAction(named: Text("Edit")) {
                        selectedCard = card
                    }
                    .accessibilityAction(named: Text("Delete")) {
                        deleteCard(card)
                    }
                }
                .onDelete(perform: deleteCards)
            } header: {
                if !nearbyCards.isEmpty && searchText.isEmpty {
                    Text(String(localized: "All Cards"))
                }
            }
        }
        .onAppear {
            checkAlwaysPermissionConditions()
            
            // Request location for widgets if user has cards with locations
            if allCards.contains(where: { !$0.locations.isEmpty }) {
                locationManager.requestLocation()
            }
        }
    }
    
    private var alwaysPermissionBanner: some View {
        HStack(spacing: 12) {
            Image(systemName: "info.circle.fill")
                .foregroundStyle(.blue)
                .font(.title3)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(String(localized: "Enable 'Always' Location"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
                Text(String(localized: "Get better widget performance with background location"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            
            Spacer()
            
            Button {
                SharedDataManager.markAlwaysBannerDismissed()
                showAlwaysBanner = false
                showingSettings = true
            } label: {
                Text(String(localized: "Enable"))
                    .font(.subheadline)
                    .fontWeight(.semibold)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            
            Button {
                SharedDataManager.markAlwaysBannerDismissed()
                showAlwaysBanner = false
            } label: {
                Image(systemName: "xmark")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(Color.blue.opacity(0.1))
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Cards", systemImage: "creditcard")
        } description: {
            if !searchText.isEmpty {
                Text("No cards matching '\(searchText)'")
            } else if !showExpiredCards && !allCards.filter({ $0.isExpired }).isEmpty {
                Text(String(localized: "All cards are expired. Toggle 'Show Expired' in the sort menu to see them."))
            } else {
                Text("Add your first loyalty card")
            }
        } actions: {
            if searchText.isEmpty && (showExpiredCards || allCards.filter({ $0.isExpired }).isEmpty) {
                Button(String(localized: "Add Card")) {
                    showingMerchantSelection = true
                }
                .buttonStyle(.borderedProminent)
                .accessibilityIdentifier("addCardButton")
            }
        }
    }
    
    private var sortMenu: some View {
        Menu {
            Picker(selection: $sortOption, label: Text("Sort")) {
                ForEach(SortOption.allCases, id: \.self) { option in
                    Text(option.localizedName).tag(option)
                }
            }
            
            Divider()
            
            Toggle(isOn: $showExpiredCards) {
                Label(String(localized: "Show Expired"), systemImage: "calendar.badge.exclamationmark")
            }
        } label: {
            Label("Sort", systemImage: "arrow.up.arrow.down")
        }
    }
    
    private var addButton: some View {
        Button(action: { showingMerchantSelection = true }) {
            Label(String(localized: "Add Card"), systemImage: "plus")
        }
        .accessibilityIdentifier("addCardButton")
    }
    
    private func toggleFavorite(_ card: LoyaltyCard) {
        withAnimation {
            card.isFavorite.toggle()
        }
    }
    
    private func shareCard(_ card: LoyaltyCard) {
        do {
            let data = try CardExporter.exportCard(card)
            let fileName = CardExporter.generateFileName(cardCount: 1, cardName: card.name)
            let fileURL = try CardExporter.createTemporaryFile(from: data, fileName: fileName)
            
            shareItem = ShareItem(url: fileURL)
        } catch {
            print("Failed to export card: \(error)")
        }
    }
    
    private func deleteCard(_ card: LoyaltyCard) {
        withAnimation {
            modelContext.delete(card)
        }
        
        // Reload all widgets since card was deleted
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredAndSortedCards[index])
            }
        }
        
        // Reload all widgets since cards were deleted
        WidgetCenter.shared.reloadAllTimelines()
    }
    
    private func handleOpenURL(_ url: URL) {
        // Check if it's a .kartonche file
        if url.pathExtension == "kartonche" {
            handleFileImport(url)
        }
        // Check if it's a deep link
        else if url.scheme == "kartonche" {
            handleDeepLink(url)
        }
    }
    
    private func handleFileImport(_ url: URL) {
        do {
            // Access the security-scoped resource
            guard url.startAccessingSecurityScopedResource() else {
                print("Failed to access security-scoped resource")
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            // Read the file data
            let data = try Data(contentsOf: url)
            
            // Parse and validate
            let container = try CardImporter.importFromData(data)
            
            // Show import preview
            importContainer = container
            showingImportPreview = true
            
        } catch {
            print("Failed to import file: \(error)")
            // TODO: Show error alert
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        guard url.host == "card",
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems,
              let idString = queryItems.first(where: { $0.name == "id" })?.value,
              let cardID = UUID(uuidString: idString) else {
            return
        }
        
        if let card = allCards.first(where: { $0.id == cardID }) {
            navigationPath.append(card)
        }
    }
    
    @MainActor
    private func importCards(container: CardExportContainer, strategy: CardImporter.ImportStrategy) async throws -> CardImporter.ImportResult {
        let result = try CardImporter.importCards(
            from: container,
            into: modelContext,
            strategy: strategy
        )
        
        // Reload widgets if cards were imported
        if result.hasChanges {
            WidgetCenter.shared.reloadAllTimelines()
        }
        
        return result
    }
    
    private func checkAlwaysPermissionConditions() {
        // Track app launches
        SharedDataManager.incrementAppLaunchCount()
        
        // Check if we should show the Always permission prompt/banner
        guard locationManager.authorizationStatus == .authorizedWhenInUse,
              !allCards.filter({ !$0.locations.isEmpty }).isEmpty else {
            return
        }
        
        let launchCount = SharedDataManager.getAppLaunchCount()
        let hasShownPrompt = SharedDataManager.hasShownAlwaysPrompt()
        let hasDismissedBanner = SharedDataManager.hasDismissedAlwaysBanner()
        
        // Show one-time prompt after 3 launches (if not shown before)
        if launchCount >= 3 && !hasShownPrompt {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                SharedDataManager.markAlwaysPromptShown()
                showingAlwaysPrompt = true
            }
        }
        // Otherwise show banner (if not dismissed)
        else if !hasDismissedBanner {
            showAlwaysBanner = true
        }
    }
}

#Preview {
    CardListView()
        .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

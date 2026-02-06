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
    @State private var showingMerchantSelection = false
    @State private var merchantForProgramSelection: MerchantTemplate?
    @State private var pendingCard: PendingCard?
    @State private var selectedCard: LoyaltyCard?
    @State private var navigationPath = NavigationPath()
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
        return locationManager.cardsNearby(allCards, radius: 1000.0)
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
            Group {
                if filteredAndSortedCards.isEmpty {
                    emptyStateView
                } else {
                    cardListView
                }
            }
            .navigationTitle(String(localized: "Loyalty Cards"))
            .navigationDestination(for: LoyaltyCard.self) { card in
                CardDisplayView(card: card)
                    .navigationBarHidden(true)
            }
            .onOpenURL { url in
                handleDeepLink(url)
            }
            .searchable(text: $searchText, prompt: String(localized: "Search"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
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
            locationManager.requestLocation()
        }
    }
    
    private var emptyStateView: some View {
        ContentUnavailableView {
            Label("No Cards", systemImage: "creditcard")
        } description: {
            if searchText.isEmpty {
                Text("Add your first loyalty card")
            } else {
                Text("No cards matching '\(searchText)'")
            }
        } actions: {
            if searchText.isEmpty {
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
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "kartonche",
              url.host == "card",
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
}

#Preview {
    CardListView()
        .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

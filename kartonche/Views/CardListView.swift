//
//  CardListView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import SwiftData

struct PendingCard: Identifiable {
    let id = UUID()
    let merchant: MerchantTemplate
    let program: ProgramTemplate?
}

struct CardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var allCards: [LoyaltyCard]
    
    @State private var searchText = ""
    @State private var sortOption: SortOption = .alphabetical
    @State private var showingMerchantSelection = false
    @State private var merchantForProgramSelection: MerchantTemplate?
    @State private var pendingCard: PendingCard?
    @State private var selectedCard: LoyaltyCard?
    
    enum SortOption: String, CaseIterable {
        case alphabetical = "Alphabetical"
        case recent = "Recent"
        case favorites = "Favorites"
        
        var localizedName: String {
            String(localized: String.LocalizationValue(rawValue))
        }
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
        }
        
        return cards
    }
    
    var body: some View {
        NavigationStack {
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
            }
            .onDelete(perform: deleteCards)
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
    }
    
    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(filteredAndSortedCards[index])
            }
        }
    }
}

#Preview {
    CardListView()
        .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

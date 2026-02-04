//
//  ContentView.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var cards: [LoyaltyCard]

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(cards) { card in
                    NavigationLink {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(card.name)
                                .font(.headline)
                            Text(card.storeName)
                                .font(.subheadline)
                            Text(card.cardNumber)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } label: {
                        VStack(alignment: .leading) {
                            Text(card.name)
                                .font(.headline)
                            Text(card.storeName)
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                .onDelete(perform: deleteCards)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button(action: addTestCard) {
                        Label(String(localized: "Add Card"), systemImage: "plus")
                    }
                }
            }
            .navigationTitle(String(localized: "Loyalty Cards"))
        } detail: {
            Text(String(localized: "Select a card"))
        }
    }

    private func addTestCard() {
        withAnimation {
            let newCard = LoyaltyCard(
                name: "Test Card",
                storeName: "Test Store",
                cardNumber: "1234567890",
                barcodeType: .qr,
                barcodeData: "1234567890"
            )
            modelContext.insert(newCard)
        }
    }

    private func deleteCards(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(cards[index])
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

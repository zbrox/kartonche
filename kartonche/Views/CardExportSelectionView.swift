//
//  CardExportSelectionView.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData

struct CardExportSelectionView: View {
    @Query private var allCards: [LoyaltyCard]
    @State private var selectedCardIDs: Set<PersistentIdentifier> = []
    @State private var shareItem: ShareItem?

    private struct ShareItem: Identifiable {
        let id = UUID()
        let url: URL
    }

    private var allSelected: Bool {
        selectedCardIDs.count == allCards.count
    }

    private var selectedCards: [LoyaltyCard] {
        allCards.filter { selectedCardIDs.contains($0.persistentModelID) }
    }

    var body: some View {
        List {
            ForEach(allCards) { card in
                Button {
                    toggleSelection(card)
                } label: {
                    HStack(spacing: 12) {
                        Image(systemName: selectedCardIDs.contains(card.persistentModelID) ? "checkmark.circle.fill" : "circle")
                            .foregroundStyle(selectedCardIDs.contains(card.persistentModelID) ? Color.accentColor : .secondary)
                            .font(.title3)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(card.color.flatMap { Color(hex: $0) } ?? .accentColor)
                            .frame(width: 4, height: 44)

                        VStack(alignment: .leading, spacing: 4) {
                            Text(card.name)
                                .font(.headline)
                            if let storeName = card.storeName, !storeName.isEmpty {
                                Text(storeName)
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }
                            if !card.cardNumber.isEmpty {
                                Text(card.cardNumber)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }

                        Spacer()

                        Text(card.barcodeType.rawValue.uppercased())
                            .font(.caption2)
                            .fontWeight(.semibold)
                            .padding(.horizontal, 6)
                            .padding(.vertical, 2)
                            .background(.secondary.opacity(0.2))
                            .cornerRadius(4)
                    }
                }
                .tint(.primary)
            }
        }
        .navigationTitle(String(localized: "Select Cards"))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    exportSelectedCards()
                } label: {
                    Text(String(localized: "Export (\(selectedCards.count))"))
                }
                .disabled(selectedCards.isEmpty)
            }

            ToolbarItem(placement: .secondaryAction) {
                Button {
                    toggleSelectAll()
                } label: {
                    Text(allSelected
                         ? String(localized: "Deselect All")
                         : String(localized: "Select All"))
                }
            }
        }
        .sheet(item: $shareItem) { item in
            ActivityViewController(activityItems: [item.url])
                .ignoresSafeArea()
        }
    }

    private func toggleSelection(_ card: LoyaltyCard) {
        if selectedCardIDs.contains(card.persistentModelID) {
            selectedCardIDs.remove(card.persistentModelID)
        } else {
            selectedCardIDs.insert(card.persistentModelID)
        }
    }

    private func toggleSelectAll() {
        if allSelected {
            selectedCardIDs.removeAll()
        } else {
            selectedCardIDs = Set(allCards.map { $0.persistentModelID })
        }
    }

    private func exportSelectedCards() {
        do {
            let cards = selectedCards
            let data = try CardExporter.exportCards(cards)
            let fileName = CardExporter.generateFileName(cardCount: cards.count)
            let fileURL = try CardExporter.createTemporaryFile(from: data, fileName: fileName)
            shareItem = ShareItem(url: fileURL)
        } catch {
            // Export errors are unlikely with valid in-memory cards
            print("Failed to export cards: \(error)")
        }
    }
}

#Preview {
    NavigationStack {
        CardExportSelectionView()
            .modelContainer(for: LoyaltyCard.self, inMemory: true)
    }
}

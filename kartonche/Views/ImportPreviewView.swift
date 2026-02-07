//
//  ImportPreviewView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import SwiftData

/// Preview view for importing cards from .kartonche files
struct ImportPreviewView: View {
    let container: CardExportContainer
    let existingCards: [LoyaltyCard]
    let onImport: (CardImporter.ImportStrategy) async throws -> CardImporter.ImportResult
    let onCancel: () -> Void
    
    @State private var importStrategy: CardImporter.ImportStrategy = .skipDuplicates
    @State private var isImporting = false
    @State private var importError: Error?
    @State private var showError = false
    
    private var duplicates: [CardImporter.DuplicateInfo] {
        CardImporter.detectDuplicates(container.cards, existingCards: existingCards)
    }
    
    var body: some View {
        NavigationStack {
            List {
                // Summary section
                Section {
                    HStack {
                        Text(String(localized: "Cards to import"))
                        Spacer()
                        Text("\(container.cards.count)")
                            .foregroundStyle(.secondary)
                    }
                    
                    if !duplicates.isEmpty {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                            Text(String(localized: "Duplicates found"))
                            Spacer()
                            Text("\(duplicates.count)")
                                .foregroundStyle(.secondary)
                        }
                    }
                    
                    HStack {
                        Text(String(localized: "Export date"))
                        Spacer()
                        Text(container.exportDate, style: .date)
                            .foregroundStyle(.secondary)
                    }
                }
                
                // Duplicate handling strategy (only if duplicates exist)
                if !duplicates.isEmpty {
                    Section {
                        Picker(String(localized: "Duplicate handling"), selection: $importStrategy) {
                            Text(String(localized: "Skip duplicates"))
                                .tag(CardImporter.ImportStrategy.skipDuplicates)
                            Text(String(localized: "Replace existing"))
                                .tag(CardImporter.ImportStrategy.replaceDuplicates)
                            Text(String(localized: "Keep both"))
                                .tag(CardImporter.ImportStrategy.keepBoth)
                        }
                        .pickerStyle(.inline)
                    } header: {
                        Text(String(localized: "How to handle duplicates"))
                    } footer: {
                        Text(strategyDescription)
                    }
                }
                
                // Card list
                Section {
                    ForEach(container.cards) { cardDTO in
                        CardImportRow(
                            card: cardDTO,
                            isDuplicate: duplicates.contains { $0.importedCard.id == cardDTO.id }
                        )
                    }
                } header: {
                    Text(String(localized: "Cards"))
                }
            }
            .navigationTitle(String(localized: "Import Cards"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        onCancel()
                    }
                    .disabled(isImporting)
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Import")) {
                        Task {
                            await performImport()
                        }
                    }
                    .disabled(isImporting || willImportNothing)
                }
            }
            .overlay {
                if isImporting {
                    ProgressView(String(localized: "Importing..."))
                        .padding()
                        .background(.regularMaterial)
                        .cornerRadius(12)
                }
            }
            .alert(String(localized: "Import Failed"), isPresented: $showError) {
                Button(String(localized: "OK")) {
                    showError = false
                }
            } message: {
                if let error = importError {
                    Text(error.localizedDescription)
                }
            }
        }
    }
    
    private var strategyDescription: String {
        switch importStrategy {
        case .skipDuplicates:
            return String(localized: "Duplicate cards will not be imported")
        case .replaceDuplicates:
            return String(localized: "Existing cards will be replaced with imported versions")
        case .keepBoth:
            return String(localized: "All cards will be imported, even duplicates")
        }
    }
    
    private var willImportNothing: Bool {
        importStrategy == .skipDuplicates && duplicates.count == container.cards.count
    }
    
    private func performImport() async {
        isImporting = true
        
        do {
            let result = try await onImport(importStrategy)
            
            // Success - dismiss handled by parent
            if result.hasChanges {
                onCancel() // Close the sheet
            }
        } catch {
            importError = error
            showError = true
        }
        
        isImporting = false
    }
}

/// Row view for a single card in the import preview
struct CardImportRow: View {
    let card: CardExportDTO
    let isDuplicate: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Card color indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(card.color.flatMap { Color(hex: $0) } ?? .accentColor)
                .frame(width: 4, height: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(card.name)
                        .font(.headline)
                    
                    if isDuplicate {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                            .font(.caption)
                    }
                }
                
                Text(card.storeName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !card.cardNumber.isEmpty {
                    Text(card.cardNumber)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
            Spacer()
            
            // Barcode type badge
            Text(card.barcodeType.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: LoyaltyCard.self, configurations: config)
    let context = container.mainContext
    
    // Create sample existing card
    let existingCard = LoyaltyCard(
        name: "Billa Club",
        storeName: "Billa",
        cardNumber: "1234567890123",
        barcodeType: .ean13,
        barcodeData: "1234567890123"
    )
    let _ = context.insert(existingCard)
    
    // Create second card for import
    let importCard = LoyaltyCard(
        name: "Kaufland Card",
        storeName: "Kaufland",
        cardNumber: "9876543210",
        barcodeType: .code128,
        barcodeData: "9876543210",
        color: "#0066CC"
    )
    
    // Create sample import container
    let importDTO1 = CardExportDTO(from: existingCard) // Duplicate
    let importDTO2 = CardExportDTO(from: importCard) // New card
    
    let exportContainer = CardExportContainer(cards: [importDTO1, importDTO2])
    
    ImportPreviewView(
        container: exportContainer,
        existingCards: [existingCard],
        onImport: { strategy in
            try await Task.sleep(for: .seconds(1))
            return CardImporter.ImportResult(
                importedCount: 1,
                skippedCount: 1,
                replacedCount: 0,
                duplicatesDetected: 1
            )
        },
        onCancel: { }
    )
}

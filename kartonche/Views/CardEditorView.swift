//
//  CardEditorView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import SwiftData
import PhotosUI

/// Editor view for creating or modifying a loyalty card
struct CardEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: LoyaltyCard?
    
    @State private var name: String
    @State private var storeName: String
    @State private var cardNumber: String
    @State private var barcodeType: BarcodeType
    @State private var barcodeData: String
    @State private var notes: String
    @State private var selectedColor: Color?
    @State private var isFavorite: Bool
    @State private var showingDeleteConfirmation = false
    @State private var photoItem: PhotosPickerItem?
    
    private var isEditMode: Bool { card != nil }
    
    init(card: LoyaltyCard? = nil) {
        self.card = card
        _name = State(initialValue: card?.name ?? "")
        _storeName = State(initialValue: card?.storeName ?? "")
        _cardNumber = State(initialValue: card?.cardNumber ?? "")
        _barcodeType = State(initialValue: card?.barcodeType ?? .qr)
        _barcodeData = State(initialValue: card?.barcodeData ?? "")
        _notes = State(initialValue: card?.notes ?? "")
        _selectedColor = State(initialValue: card?.color.flatMap { Color(hex: $0) })
        _isFavorite = State(initialValue: card?.isFavorite ?? false)
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Card Name", text: $name)
                    TextField("Store Name", text: $storeName)
                    TextField("Card Number", text: $cardNumber)
                }
                
                Section {
                    Picker("Barcode Type", selection: $barcodeType) {
                        ForEach(BarcodeType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    
                    TextField("Barcode Data", text: $barcodeData)
                    
                    if !barcodeData.isEmpty {
                        BarcodeImageView(data: barcodeData, type: barcodeType)
                            .frame(height: 120)
                    }
                }
                
                Section {
                    ColorPicker("Card Color", selection: Binding(
                        get: { selectedColor ?? .gray },
                        set: { selectedColor = $0 }
                    ), supportsOpacity: false)
                    
                    Toggle("Favorite", isOn: $isFavorite)
                }
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
                }
                
                Section {
                    PhotosPicker(selection: $photoItem, matching: .images) {
                        Label("Attach Photo", systemImage: "photo")
                    }
                }
                
                if isEditMode {
                    Section {
                        Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                            Text(String(localized: "Delete"))
                        }
                    }
                }
            }
            .navigationTitle(isEditMode ? String(localized: "Edit") : String(localized: "Add Card"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Save")) {
                        saveCard()
                    }
                    .disabled(!isValid)
                }
            }
            .confirmationDialog(
                "Are you sure you want to delete this card?",
                isPresented: $showingDeleteConfirmation,
                titleVisibility: .visible
            ) {
                Button("Delete", role: .destructive) {
                    deleteCard()
                }
            }
        }
    }
    
    private var isValid: Bool {
        !name.isEmpty && !storeName.isEmpty && !barcodeData.isEmpty
    }
    
    private func saveCard() {
        if let existingCard = card {
            existingCard.name = name
            existingCard.storeName = storeName
            existingCard.cardNumber = cardNumber
            existingCard.barcodeType = barcodeType
            existingCard.barcodeData = barcodeData
            existingCard.notes = notes.isEmpty ? nil : notes
            existingCard.color = selectedColor?.toHex()
            existingCard.isFavorite = isFavorite
        } else {
            let newCard = LoyaltyCard(
                name: name,
                storeName: storeName,
                cardNumber: cardNumber,
                barcodeType: barcodeType,
                barcodeData: barcodeData,
                color: selectedColor?.toHex(),
                notes: notes.isEmpty ? nil : notes,
                isFavorite: isFavorite
            )
            modelContext.insert(newCard)
        }
        
        dismiss()
    }
    
    private func deleteCard() {
        if let card = card {
            modelContext.delete(card)
            dismiss()
        }
    }
}

extension Color {
    /// Convert Color to hex string
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
}

#Preview {
    CardEditorView()
        .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

#Preview("Edit Mode") {
    CardEditorView(
        card: LoyaltyCard(
            name: "Billa Club",
            storeName: "Billa",
            cardNumber: "1234567890123",
            barcodeType: .ean13,
            barcodeData: "1234567890123",
            color: "#FF0000",
            isFavorite: true
        )
    )
    .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

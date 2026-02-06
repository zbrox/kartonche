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
    let merchantTemplate: MerchantTemplate?
    
    @State private var name: String
    @State private var storeName: String
    @State private var cardNumber: String
    @State private var barcodeType: BarcodeType
    @State private var barcodeData: String
    @State private var notes: String
    @State private var selectedColor: Color?
    @State private var isFavorite: Bool
    @State private var expirationDate: Date?
    @State private var hasExpirationDate: Bool
    @State private var showingDeleteConfirmation = false
    @State private var showingScanner = false
    @State private var scannedBarcode: ScannedBarcode?
    @State private var photoPickerItem: PhotosPickerItem?
    @State private var isProcessingPhoto = false
    @State private var scanError: String?
    @State private var showingMultipleBarcodes = false
    @State private var detectedBarcodes: [ScannedBarcode] = []
    
    private var isEditMode: Bool { card != nil }
    
    init(card: LoyaltyCard? = nil, merchantTemplate: MerchantTemplate? = nil, program: ProgramTemplate? = nil) {
        self.card = card
        self.merchantTemplate = merchantTemplate
        
        if let card = card {
            // Edit mode - use card data
            _name = State(initialValue: card.name)
            _storeName = State(initialValue: card.storeName)
            _cardNumber = State(initialValue: card.cardNumber)
            _barcodeType = State(initialValue: card.barcodeType)
            _barcodeData = State(initialValue: card.barcodeData)
            _notes = State(initialValue: card.notes ?? "")
            _selectedColor = State(initialValue: card.color.flatMap { Color(hex: $0) })
            _isFavorite = State(initialValue: card.isFavorite)
            _expirationDate = State(initialValue: card.expirationDate)
            _hasExpirationDate = State(initialValue: card.expirationDate != nil)
        } else if let merchant = merchantTemplate, let program = program {
            // New card from merchant template
            _name = State(initialValue: program.name ?? merchant.name)
            _storeName = State(initialValue: merchant.name)
            _cardNumber = State(initialValue: "")
            _barcodeType = State(initialValue: program.barcodeType)
            _barcodeData = State(initialValue: "")
            _notes = State(initialValue: "")
            _selectedColor = State(initialValue: Color(hex: merchant.suggestedColor))
            _isFavorite = State(initialValue: false)
            _expirationDate = State(initialValue: nil)
            _hasExpirationDate = State(initialValue: false)
        } else {
            // New custom card - empty
            _name = State(initialValue: "")
            _storeName = State(initialValue: "")
            _cardNumber = State(initialValue: "")
            _barcodeType = State(initialValue: .qr)
            _barcodeData = State(initialValue: "")
            _notes = State(initialValue: "")
            _selectedColor = State(initialValue: nil)
            _isFavorite = State(initialValue: false)
            _expirationDate = State(initialValue: nil)
            _hasExpirationDate = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("Card Name", text: $name)
                        .accessibilityIdentifier("cardNameField")
                    TextField("Store Name", text: $storeName)
                        .accessibilityIdentifier("storeNameField")
                    TextField("Card Number", text: $cardNumber)
                        .accessibilityIdentifier("cardNumberField")
                }
                
                Section {
                    if BarcodeScannerView.isSupported {
                        Button {
                            showingScanner = true
                        } label: {
                            Label(String(localized: "Scan Barcode"), systemImage: "barcode.viewfinder")
                        }
                        .accessibilityIdentifier("scanBarcodeButton")
                        .accessibilityHint(String(localized: "Opens camera to scan barcode"))
                    }
                    
                    PhotosPicker(selection: $photoPickerItem, matching: .images) {
                        Label(String(localized: "Scan from Photo"), systemImage: "photo")
                    }
                    .disabled(isProcessingPhoto)
                    .accessibilityIdentifier("scanPhotoButton")
                    .accessibilityHint(String(localized: "Select photo from library to scan barcode"))
                    
                    if isProcessingPhoto {
                        HStack {
                            ProgressView()
                            Text(String(localized: "Scanning..."))
                        }
                    }
                    
                    if let error = scanError {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                    }
                    
                    Picker("Barcode Type", selection: $barcodeType) {
                        ForEach(BarcodeType.allCases, id: \.self) { type in
                            Text(type.displayName).tag(type)
                        }
                    }
                    .accessibilityIdentifier("barcodeTypePicker")
                    
                    TextField("Barcode Data", text: $barcodeData)
                        .accessibilityIdentifier("barcodeDataField")
                    
                    if !barcodeData.isEmpty {
                        BarcodeImageView(data: barcodeData, type: barcodeType)
                            .frame(height: 120)
                            .accessibilityLabel(String(localized: "Barcode preview"))
                            .accessibilityValue("\(barcodeType.displayName), \(barcodeData)")
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
                    Toggle(String(localized: "Has Expiration Date"), isOn: $hasExpirationDate)
                        .onChange(of: hasExpirationDate) { oldValue, newValue in
                            if newValue && expirationDate == nil {
                                // Initialize with a date 1 year from now when toggle is enabled
                                expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
                            }
                        }
                    
                    if hasExpirationDate {
                        DatePicker(
                            String(localized: "Expiration Date"),
                            selection: Binding(
                                get: { expirationDate ?? Date() },
                                set: { expirationDate = $0 }
                            ),
                            displayedComponents: .date
                        )
                    }
                }
                
                Section {
                    TextField("Notes", text: $notes, axis: .vertical)
                        .lineLimit(3...6)
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
                    .accessibilityIdentifier("saveButton")
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
            .sheet(isPresented: $showingScanner) {
                BarcodeScannerView(scannedBarcode: $scannedBarcode) {
                    showingScanner = false
                }
            }
            .onChange(of: scannedBarcode) { oldValue, newValue in
                guard let scanned = newValue else { return }
                barcodeData = scanned.data
                if let detectedType = BarcodeType(from: scanned.symbology) {
                    barcodeType = detectedType
                }
                scannedBarcode = nil
            }
            .onChange(of: photoPickerItem) { oldValue, newValue in
                guard let item = newValue else { return }
                scanBarcodeFromPhoto(item)
            }
            .alert("Multiple Barcodes Found", isPresented: $showingMultipleBarcodes) {
                ForEach(detectedBarcodes.indices, id: \.self) { index in
                    Button(detectedBarcodes[index].data) {
                        selectBarcode(detectedBarcodes[index])
                    }
                }
                Button("Cancel", role: .cancel) {
                    detectedBarcodes = []
                }
            } message: {
                Text("Select which barcode to use")
            }
        }
    }
    
    private func scanBarcodeFromPhoto(_ item: PhotosPickerItem) {
        isProcessingPhoto = true
        scanError = nil
        
        Task {
            do {
                guard let imageData = try await item.loadTransferable(type: Data.self),
                      let uiImage = UIImage(data: imageData) else {
                    await MainActor.run {
                        scanError = String(localized: "Failed to load image")
                        isProcessingPhoto = false
                        photoPickerItem = nil
                    }
                    return
                }
                
                let barcodes = try await PhotoBarcodeScanner.scanBarcodes(from: uiImage)
                
                await MainActor.run {
                    if barcodes.count == 1 {
                        selectBarcode(barcodes[0])
                    } else {
                        detectedBarcodes = barcodes
                        showingMultipleBarcodes = true
                    }
                    isProcessingPhoto = false
                    photoPickerItem = nil
                }
            } catch {
                await MainActor.run {
                    scanError = error.localizedDescription
                    isProcessingPhoto = false
                    photoPickerItem = nil
                }
            }
        }
    }
    
    private func selectBarcode(_ barcode: ScannedBarcode) {
        barcodeData = barcode.data
        if let detectedType = BarcodeType(from: barcode.symbology) {
            barcodeType = detectedType
        }
        detectedBarcodes = []
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
            existingCard.secondaryColor = merchantTemplate?.secondaryColor
            existingCard.isFavorite = isFavorite
            existingCard.expirationDate = hasExpirationDate ? expirationDate : nil
        } else {
            let newCard = LoyaltyCard(
                name: name,
                storeName: storeName,
                cardNumber: cardNumber,
                barcodeType: barcodeType,
                barcodeData: barcodeData,
                color: selectedColor?.toHex(),
                secondaryColor: merchantTemplate?.secondaryColor,
                notes: notes.isEmpty ? nil : notes,
                isFavorite: isFavorite,
                expirationDate: hasExpirationDate ? expirationDate : nil
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

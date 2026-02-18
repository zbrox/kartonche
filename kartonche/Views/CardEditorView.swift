//
//  CardEditorView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import SwiftData
import PhotosUI
import WidgetKit
import PassKit

/// Editor view for creating or modifying a loyalty card
struct CardEditorView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    let card: LoyaltyCard?
    let merchantTemplate: MerchantTemplate?
    
    @State private var name: String
    @State private var storeName: String
    @State private var cardholderName: String
    @State private var cardNumber: String
    @State private var barcodeType: BarcodeType
    @State private var barcodeData: String
    @State private var notes: String
    @State private var selectedColor: Color?
    @State private var selectedSecondaryColor: Color?
    @State private var useAutoTextColor: Bool
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
    @State private var showingLocationEditor = false
    @State private var editingLocation: CardLocation?
    @State private var pendingLocations: [CardLocation] = []
    @State private var showingNotificationPermission = false
    @State private var cardImageData: Data?
    @State private var cardImagePickerItem: PhotosPickerItem?
    @State private var showingImageCrop = false
    @State private var rawImageForCrop: UIImage?
    
    private var isEditMode: Bool { card != nil }
    
    private var effectiveSecondaryColor: Color {
        if useAutoTextColor {
            return (selectedColor ?? .gray).contrastingTextColor()
        }
        return selectedSecondaryColor ?? .white
    }
    
    private var cardInitials: String {
        let displayName = name.isEmpty ? storeName : name
        let words = displayName.split(separator: " ")
        if words.count >= 2 {
            return words.prefix(2)
                .compactMap { $0.first.map(String.init) }
                .joined()
                .uppercased()
        } else if let first = displayName.first {
            return String(first).uppercased()
        }
        return "?"
    }
    
    private var displayedLocations: [CardLocation] {
        if let card = card {
            return card.locations
        } else {
            return pendingLocations
        }
    }
    
    init(card: LoyaltyCard? = nil, merchantTemplate: MerchantTemplate? = nil, program: ProgramTemplate? = nil) {
        self.card = card
        self.merchantTemplate = merchantTemplate
        
        if let card = card {
            // Edit mode - use card data
            _name = State(initialValue: card.name)
            _storeName = State(initialValue: card.storeName ?? "")
            _cardholderName = State(initialValue: card.cardholderName ?? "")
            _cardNumber = State(initialValue: card.cardNumber ?? "")
            _barcodeType = State(initialValue: card.barcodeType)
            _barcodeData = State(initialValue: card.barcodeData)
            _notes = State(initialValue: card.notes ?? "")
            _selectedColor = State(initialValue: card.color.flatMap { Color(hex: $0) })
            _selectedSecondaryColor = State(initialValue: card.secondaryColor.flatMap { Color(hex: $0) })
            _useAutoTextColor = State(initialValue: card.secondaryColor == nil)
            _isFavorite = State(initialValue: card.isFavorite)
            _expirationDate = State(initialValue: card.expirationDate)
            _hasExpirationDate = State(initialValue: card.expirationDate != nil)
            _cardImageData = State(initialValue: card.cardImage)
        } else if let merchant = merchantTemplate, let program = program {
            // New card from merchant template
            _name = State(initialValue: program.name ?? merchant.name)
            _storeName = State(initialValue: merchant.name)
            _cardholderName = State(initialValue: "")
            _cardNumber = State(initialValue: "")
            _barcodeType = State(initialValue: program.barcodeType)
            _barcodeData = State(initialValue: "")
            _notes = State(initialValue: "")
            _selectedColor = State(initialValue: Color(hex: merchant.suggestedColor))
            _selectedSecondaryColor = State(initialValue: Color(hex: merchant.secondaryColor))
            _useAutoTextColor = State(initialValue: merchant.secondaryColor == nil)
            _isFavorite = State(initialValue: false)
            _expirationDate = State(initialValue: nil)
            _hasExpirationDate = State(initialValue: false)
        } else {
            // New custom card - empty
            _name = State(initialValue: "")
            _storeName = State(initialValue: "")
            _cardholderName = State(initialValue: "")
            _cardNumber = State(initialValue: "")
            _barcodeType = State(initialValue: .qr)
            _barcodeData = State(initialValue: "")
            _notes = State(initialValue: "")
            _selectedColor = State(initialValue: nil)
            _selectedSecondaryColor = State(initialValue: nil)
            _useAutoTextColor = State(initialValue: true)
            _isFavorite = State(initialValue: false)
            _expirationDate = State(initialValue: nil)
            _hasExpirationDate = State(initialValue: false)
        }
    }
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField(text: $name, prompt: Text("\(String(localized: "Card Name")) \(Text("*").foregroundColor(.red))")) {
                        Text(String(localized: "Card Name"))
                    }
                        .accessibilityIdentifier("cardNameField")
                    TextField("Store Name", text: $storeName)
                        .accessibilityIdentifier("storeNameField")
                    TextField(String(localized: "Cardholder Name"), text: $cardholderName)
                        .accessibilityIdentifier("cardholderNameField")
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
                    
                    TextField(text: $barcodeData, prompt: Text("\(String(localized: "Barcode Data")) \(Text("*").foregroundColor(.red))")) {
                        Text(String(localized: "Barcode Data"))
                    }
                        .accessibilityIdentifier("barcodeDataField")
                    
                    if !barcodeData.isEmpty {
                        BarcodeImageView(data: barcodeData, type: barcodeType)
                            .frame(height: 120)
                            .accessibilityLabel(String(localized: "Barcode preview"))
                            .accessibilityValue("\(barcodeType.displayName), \(barcodeData)")
                    }
                }
                
                Section {
                    // Mini card preview
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(selectedColor ?? .gray)
                                .frame(width: 60, height: 60)
                            
                            Text(cardInitials)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundStyle(effectiveSecondaryColor)
                        }
                        
                        Text(name.isEmpty ? String(localized: "Card Name") : name)
                            .font(.headline)
                            .foregroundStyle(.primary)
                        
                        Text(storeName.isEmpty ? String(localized: "Store Name") : storeName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.vertical, 8)
                    .alignmentGuide(.listRowSeparatorLeading) { _ in 0 }
                    
                    ColorPicker(String(localized: "Card Color"), selection: Binding(
                        get: { selectedColor ?? .gray },
                        set: { selectedColor = $0 }
                    ), supportsOpacity: false)
                    
                    Picker(String(localized: "Text Color"), selection: $useAutoTextColor) {
                        Text(String(localized: "Auto")).tag(true)
                        Text(String(localized: "Custom")).tag(false)
                    }
                    .pickerStyle(.segmented)
                    .onChange(of: useAutoTextColor) { _, newValue in
                        if !newValue && selectedSecondaryColor == nil {
                            selectedSecondaryColor = (selectedColor ?? .gray).contrastingTextColor()
                        }
                    }
                    
                    if !useAutoTextColor {
                        ColorPicker(String(localized: "Custom Text Color"), selection: Binding(
                            get: { selectedSecondaryColor ?? .white },
                            set: { selectedSecondaryColor = $0 }
                        ), supportsOpacity: false)
                    }

                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Card Image"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        if let cardImageData, let uiImage = UIImage(data: cardImageData) {
                            Image(uiImage: uiImage)
                                .resizable()
                                .aspectRatio(WalletPassConfiguration.stripAspectRatio, contentMode: .fit)
                                .clipShape(RoundedRectangle(cornerRadius: 8))
                        }

                        if cardImageData != nil {
                            Button(role: .destructive) {
                                cardImageData = nil
                            } label: {
                                Label(String(localized: "Remove Image"), systemImage: "trash")
                                    .foregroundStyle(.red)
                            }
                        } else {
                            PhotosPicker(selection: $cardImagePickerItem, matching: .images) {
                                Label(String(localized: "Choose Image"), systemImage: "photo")
                            }
                        }
                    }
                } header: {
                    Text(String(localized: "Appearance"))
                }
                
                Section {
                    Toggle(String(localized: "Favorite"), isOn: $isFavorite)
                }
                
                Section {
                    Toggle(String(localized: "Has Expiration Date"), isOn: $hasExpirationDate)
                        .onChange(of: hasExpirationDate) { oldValue, newValue in
                            if newValue {
                                // Initialize with a date 1 year from now when toggle is enabled
                                if expirationDate == nil {
                                    expirationDate = Calendar.current.date(byAdding: .year, value: 1, to: Date())
                                }
                                
                                // Show permission explanation before requesting
                                let status = NotificationManager.shared.authorizationStatus
                                if status == .notDetermined {
                                    showingNotificationPermission = true
                                }
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
                
                // Locations section
                Section {
                    ForEach(displayedLocations) { location in
                        Button {
                            editingLocation = location
                            showingLocationEditor = true
                        } label: {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(location.name)
                                    .foregroundStyle(.primary)
                                Text(location.address)
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                Text(String(localized: "Radius: \(Int(location.radius))m"))
                                    .font(.caption2)
                                    .foregroundStyle(.tertiary)
                            }
                        }
                    }
                    .onDelete(perform: deleteLocations)
                    
                    Button {
                        editingLocation = nil
                        showingLocationEditor = true
                    } label: {
                        Label(String(localized: "Add Location"), systemImage: "plus.circle.fill")
                    }
                } header: {
                    Text(String(localized: "Locations"))
                } footer: {
                    Text(String(localized: "Card will appear when you're nearby"))
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
                    .accessibilityIdentifier("cancelButton")
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
            .onChange(of: cardImagePickerItem) { _, newValue in
                guard let item = newValue else { return }
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let uiImage = UIImage(data: data) {
                        await MainActor.run {
                            rawImageForCrop = uiImage
                            showingImageCrop = true
                        }
                    }
                    await MainActor.run {
                        cardImagePickerItem = nil
                    }
                }
            }
            .sheet(isPresented: $showingImageCrop) {
                if let rawImage = rawImageForCrop {
                    ImageCropView(image: rawImage) { croppedData in
                        cardImageData = croppedData
                    }
                }
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
            .sheet(isPresented: $showingLocationEditor) {
                // Create a temporary card for the LocationEditorView if we're in create mode
                let editorCard = card ?? LoyaltyCard(
                    name: name,
                    storeName: storeName.isEmpty ? nil : storeName,
                    cardNumber: cardNumber.isEmpty ? nil : cardNumber,
                    barcodeType: barcodeType,
                    barcodeData: barcodeData
                )
                LocationEditorView(card: editorCard, location: editingLocation) { location in
                    saveLocation(location)
                }
            }
            .sheet(isPresented: $showingNotificationPermission) {
                NotificationPermissionView(
                    onAllow: {
                        showingNotificationPermission = false
                        Task {
                            await NotificationManager.shared.requestPermission()
                        }
                    },
                    onDeny: {
                        showingNotificationPermission = false
                        hasExpirationDate = false
                    }
                )
                .presentationDetents([.medium])
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
        !name.isEmpty && !barcodeData.isEmpty
    }
    
    private func saveCard() {
        let savedCard: LoyaltyCard
        
        if let existingCard = card {
            existingCard.name = name
            existingCard.storeName = storeName.isEmpty ? nil : storeName
            existingCard.cardholderName = cardholderName.isEmpty ? nil : cardholderName
            existingCard.cardNumber = cardNumber.isEmpty ? nil : cardNumber
            existingCard.barcodeType = barcodeType
            existingCard.barcodeData = barcodeData
            existingCard.notes = notes.isEmpty ? nil : notes
            existingCard.color = selectedColor?.toHex()
            existingCard.secondaryColor = useAutoTextColor ? nil : selectedSecondaryColor?.toHex()
            existingCard.isFavorite = isFavorite
            existingCard.expirationDate = hasExpirationDate ? expirationDate : nil
            existingCard.cardImage = cardImageData
            savedCard = existingCard
        } else {
            let newCard = LoyaltyCard(
                name: name,
                storeName: storeName.isEmpty ? nil : storeName,
                cardNumber: cardNumber.isEmpty ? nil : cardNumber,
                barcodeType: barcodeType,
                barcodeData: barcodeData,
                color: selectedColor?.toHex(),
                secondaryColor: useAutoTextColor ? nil : selectedSecondaryColor?.toHex(),
                notes: notes.isEmpty ? nil : notes,
                cardholderName: cardholderName.isEmpty ? nil : cardholderName,
                isFavorite: isFavorite,
                expirationDate: hasExpirationDate ? expirationDate : nil,
                cardImage: cardImageData
            )
            modelContext.insert(newCard)
            
            // Add pending locations to the new card
            for location in pendingLocations {
                location.card = newCard
                modelContext.insert(location)
            }
            savedCard = newCard
        }
        
        // Schedule or cancel expiration notifications
        Task {
            if hasExpirationDate && expirationDate != nil {
                await NotificationManager.shared.scheduleExpirationNotifications(for: savedCard)
            } else {
                await NotificationManager.shared.cancelNotifications(for: savedCard.id)
            }
        }
        
        // Reload all widgets to show updated card data
        WidgetCenter.shared.reloadAllTimelines()

        // Update Apple Wallet pass if one exists for this card
        if walletPassExists(for: savedCard) {
            Task {
                try? await updateWalletPass(for: savedCard)
            }
        }

        dismiss()
    }
    
    private func deleteCard() {
        if let card = card {
            // Cancel any pending notifications
            Task {
                await NotificationManager.shared.cancelNotifications(for: card.id)
            }

            // Remove Apple Wallet pass if one exists
            removeWalletPass(for: card)

            modelContext.delete(card)

            // Reload all widgets since card was deleted
            WidgetCenter.shared.reloadAllTimelines()

            dismiss()
        }
    }
    
    private func deleteLocations(at offsets: IndexSet) {
        if let card = card {
            // Edit mode: delete from card and database
            for index in offsets {
                let location = card.locations[index]
                modelContext.delete(location)
            }
        } else {
            // Create mode: remove from pending list
            pendingLocations.remove(atOffsets: offsets)
        }
    }
    
    private func walletPassExists(for card: LoyaltyCard) -> Bool {
        PKPassLibrary().passes().contains {
            $0.serialNumber == card.id.uuidString &&
            $0.passTypeIdentifier == WalletPassConfiguration.passTypeIdentifier
        }
    }

    private func updateWalletPass(for card: LoyaltyCard) async throws {
        let passData = try WalletPassGenerator.generate(for: card)
        let pass = try PKPass(data: passData)
        PKPassLibrary().replacePass(with: pass)
    }

    private func removeWalletPass(for card: LoyaltyCard) {
        if let pass = PKPassLibrary().passes().first(where: {
            $0.serialNumber == card.id.uuidString &&
            $0.passTypeIdentifier == WalletPassConfiguration.passTypeIdentifier
        }) {
            PKPassLibrary().removePass(pass)
        }
    }

    private func saveLocation(_ location: CardLocation) {
        if let card = card {
            // Edit mode: add to card immediately
            if !card.locations.contains(where: { $0.id == location.id }) {
                location.card = card
                modelContext.insert(location)
            }
            // If editing existing location, changes are automatically persisted
        } else {
            // Create mode: add to pending list
            if let index = pendingLocations.firstIndex(where: { $0.id == location.id }) {
                // Update existing pending location
                pendingLocations[index] = location
            } else {
                // Add new pending location
                pendingLocations.append(location)
            }
        }
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

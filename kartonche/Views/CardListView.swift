//
//  CardListView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import SwiftData
import CoreLocation
import UniformTypeIdentifiers
import UIKit
import PhotosUI
import TipKit

struct CardListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.openURL) private var openURL
    @Environment(URLRouter.self) private var urlRouter
    @Query private var allCards: [LoyaltyCard]

    @State private var searchText = ""
    @AppStorage("sortOption") private var sortOption: SortOption = .alphabetical
    @AppStorage("showExpiredCards") private var showExpiredCards = true
    @State private var selectedCard: LoyaltyCard?
    @State private var displayCard: LoyaltyCard?
    @State private var navigationPath = NavigationPath()
    @State private var showingSettings = false
    @State private var showingAlwaysPrompt = false
    @State private var showAlwaysBanner = false
    @State private var shareItem: ShareItem?
    @State private var importContainer: CardExportContainer?
    @State private var showingImportPreview = false
    @State private var showConfetti = false
    @State private var previousCardCount = 0
    @State private var showingDeleteConfirmation = false
    @State private var cardToDelete: LoyaltyCard?
    @State private var errorAlert: CardListErrorAlert?

    // Quick Scan flow state
    @State private var showingAddOptions = false
    @State private var showingCamera = false
    @State private var addFlowPickerItem: PhotosPickerItem?
    @State private var showingEditor = false
    @State private var scannedBarcodeData: String?
    @State private var scannedBarcodeType: BarcodeType?
    @State private var scannedColor: Color?
    @State private var scannedSuggestedColors: [Color] = []
    @State private var showingPhotoPicker = false
    @State private var showingBarcodeScanner = false
    @State private var photoPickerScanFailed = false
    @State private var isProcessingQuickScan = false
    @State private var pendingOpenExistingCardID: UUID?

    private let quickScanTip = QuickScanTip()
    private let swipeActionsTip = SwipeActionsTip()
    private let shareTip = ShareTip()
    private let homeScreenWidgetTip = HomeScreenWidgetTip()
    private let lockScreenWidgetTip = LockScreenWidgetTip()
    private let controlCenterWidgetTip = ControlCenterWidgetTip()
    
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
                card.storeName?.localizedCaseInsensitiveContains(searchText) == true ||
                card.cardNumber?.localizedCaseInsensitiveContains(searchText) == true
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
            .fullScreenCover(item: $displayCard) { card in
                CardDisplayView(card: card)
            }
            .onChange(of: urlRouter.pendingImportURL) { oldURL, newURL in
                if let url = newURL {
                    dismissActivePresentation()
                    handleFileImport(url)
                    urlRouter.clearPendingImport()
                }
            }
            .onChange(of: urlRouter.pendingDeepLinkURL) { oldURL, newURL in
                if let url = newURL {
                    dismissActivePresentation()
                    handleDeepLink(url)
                    urlRouter.clearPendingDeepLink()
                }
            }
            .onAppear {
                // Handle URLs that arrived before .onChange registered (cold launch)
                if let url = urlRouter.pendingDeepLinkURL {
                    dismissActivePresentation()
                    handleDeepLink(url)
                    urlRouter.clearPendingDeepLink()
                }
                if let url = urlRouter.pendingImportURL {
                    dismissActivePresentation()
                    handleFileImport(url)
                    urlRouter.clearPendingImport()
                }
            }
            .searchable(text: $searchText, prompt: String(localized: "Search"))
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gear")
                    }
                    .accessibilityIdentifier("settingsButton")
                }
                
                ToolbarItem(placement: .principal) {
                    sortMenu
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    addButton
                }
            }
            .sheet(isPresented: $showingAddOptions) {
                addOptionsSheet
            }
            .photosPicker(isPresented: $showingPhotoPicker, selection: $addFlowPickerItem, matching: .images)
            .sheet(isPresented: $showingCamera) {
                CameraCaptureView(
                    onCapture: { image in
                        processImage(image)
                    },
                    onDismiss: {
                        showingCamera = false
                    }
                )
            }
            .sheet(isPresented: $showingBarcodeScanner) {
                BarcodeScannerView(
                    scannedBarcode: .constant(nil),
                    onDismiss: {
                        showingBarcodeScanner = false
                    },
                    onScanWithPhoto: { barcode, photo in
                        handleScannerResult(barcode: barcode, photo: photo)
                    }
                )
            }
            .sheet(isPresented: $showingEditor, onDismiss: {
                presentPendingExistingCardEditorIfNeeded()
            }) {
                CardEditorView(
                    scannedBarcodeData: scannedBarcodeData,
                    scannedBarcodeType: scannedBarcodeType,
                    scannedColor: scannedColor,
                    scannedSuggestedColors: scannedSuggestedColors,
                    onOpenExistingCard: { duplicateCardID in
                        requestOpenExistingCardEditor(cardID: duplicateCardID)
                    }
                )
            }
            .onChange(of: addFlowPickerItem) { _, newValue in
                guard let item = newValue else { return }
                Task {
                    await MainActor.run {
                        isProcessingQuickScan = true
                    }

                    if let data = try? await item.loadTransferable(type: Data.self) {
                        processImageData(data)
                    } else {
                        await MainActor.run {
                            isProcessingQuickScan = false
                        }
                    }

                    await MainActor.run {
                        addFlowPickerItem = nil
                    }
                }
            }
            .sheet(item: $selectedCard, onDismiss: {
                presentPendingExistingCardEditorIfNeeded()
            }) { card in
                CardEditorView(
                    card: card,
                    onOpenExistingCard: { duplicateCardID in
                        requestOpenExistingCardEditor(cardID: duplicateCardID)
                    }
                )
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
                        duplicates: CardRepository(modelContext: modelContext).findDuplicates(for: container.cards),
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
            .alert(
                String(localized: "Are you sure you want to delete this card?"),
                isPresented: $showingDeleteConfirmation
            ) {
                Button(String(localized: "Cancel"), role: .cancel) {
                    cardToDelete = nil
                }
                Button(String(localized: "Delete"), role: .destructive) {
                    if let card = cardToDelete {
                        deleteCard(card)
                    }
                    cardToDelete = nil
                }
            }
            .alert(
                String(localized: "No Barcode Found"),
                isPresented: $photoPickerScanFailed
            ) {
                Button(String(localized: "Try Another Photo")) {
                    showingPhotoPicker = true
                }
                Button(String(localized: "Add Manually")) {
                    showingEditor = true
                }
                Button(String(localized: "Cancel"), role: .cancel) {}
            } message: {
                Text(String(localized: "Could not detect a barcode in the selected image."))
            }
            .alert(item: $errorAlert) { alert in
                Alert(
                    title: Text(alert.title),
                    message: Text(alert.message),
                    dismissButton: .default(Text(String(localized: "OK")))
                )
            }
            .confetti(isActive: $showConfetti)
            .overlay {
                if isProcessingQuickScan {
                    quickScanProgressOverlay
                }
            }
            .onAppear {
                previousCardCount = allCards.count
            }
            .onChange(of: allCards.count) { oldCount, newCount in
                if previousCardCount == 0 && newCount == 1 {
                    triggerFirstCardCelebration()
                }
                previousCardCount = newCount
            }
        }
    }
    
    private func triggerFirstCardCelebration() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        showConfetti = true
    }
    
    private var cardListView: some View {
        List {
            // Nearby Cards section
            if !nearbyCards.isEmpty && searchText.isEmpty {
                Section {
                    ForEach(nearbyCards, id: \.card.id) { nearby in
                        CardRowView(card: nearby.card, distance: nearby.distance) {
                            toggleFavorite(nearby.card)
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            displayCard = nearby.card
                        }
                        .swipeActions(edge: .leading) {
                            Button {
                                toggleFavorite(nearby.card)
                            } label: {
                                Label(
                                    nearby.card.isFavorite ? String(localized: "Unfavorite", comment: "Swipe action to remove card from favorites") : String(localized: "Favorite", comment: "Swipe action to mark card as favorite"),
                                    systemImage: nearby.card.isFavorite ? "star.slash.fill" : "star.fill"
                                )
                            }
                            .tint(.yellow)
                        }
                        .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                cardToDelete = nearby.card
                                showingDeleteConfirmation = true
                            } label: {
                                Label(String(localized: "Delete"), systemImage: "trash")
                            }
                            
                            Button {
                                selectedCard = nearby.card
                            } label: {
                                Label(String(localized: "Edit"), systemImage: "pencil")
                            }
                            .tint(.blue)
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
                                cardToDelete = nearby.card
                                showingDeleteConfirmation = true
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
                    CardRowView(card: card) {
                        toggleFavorite(card)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        displayCard = card
                    }
                    .swipeActions(edge: .leading) {
                        Button {
                            toggleFavorite(card)
                        } label: {
                            Label(
                                card.isFavorite ? String(localized: "Unfavorite", comment: "Swipe action to remove card from favorites") : String(localized: "Favorite", comment: "Swipe action to mark card as favorite"),
                                systemImage: card.isFavorite ? "star.slash.fill" : "star.fill"
                            )
                        }
                        .tint(.yellow)
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                        Button(role: .destructive) {
                            cardToDelete = card
                            showingDeleteConfirmation = true
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                        
                        Button {
                            selectedCard = card
                        } label: {
                            Label(String(localized: "Edit"), systemImage: "pencil")
                        }
                        .tint(.blue)
                    }
                    .contextMenu {
                        Button {
                            shareCard(card)
                        } label: {
                            Label(String(localized: "Share"), systemImage: "square.and.arrow.up")
                        }
                        .accessibilityIdentifier("contextMenuShare")

                        Button {
                            selectedCard = card
                        } label: {
                            Label(String(localized: "Edit"), systemImage: "pencil")
                        }
                        .accessibilityIdentifier("contextMenuEdit")

                        Button(role: .destructive) {
                            cardToDelete = card
                            showingDeleteConfirmation = true
                        } label: {
                            Label(String(localized: "Delete"), systemImage: "trash")
                        }
                    }
                    .accessibilityAction(named: Text("Edit")) {
                        selectedCard = card
                    }
                    .accessibilityAction(named: Text("Delete")) {
                        cardToDelete = card
                        showingDeleteConfirmation = true
                    }
                }

            } header: {
                if !nearbyCards.isEmpty && searchText.isEmpty {
                    Text(String(localized: "All Cards"))
                }
            }
        }
        .safeAreaInset(edge: .top, spacing: 0) {
            VStack(spacing: 4) {
                TipView(quickScanTip)
                TipView(swipeActionsTip)
                TipView(shareTip)
                TipView(homeScreenWidgetTip)
                TipView(lockScreenWidgetTip)
                TipView(controlCenterWidgetTip)
            }
            .padding(.horizontal)
            .padding(.bottom, 4)
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
    
    @ViewBuilder
    private var emptyStateView: some View {
        if !searchText.isEmpty {
            // Search with no results
            ContentUnavailableView {
                Label(String(localized: "No Results"), systemImage: "magnifyingglass")
            } description: {
                Text(String(localized: "No cards matching '\(searchText)'"))
            }
        } else if !showExpiredCards && !allCards.filter({ $0.isExpired }).isEmpty {
            // All cards are expired and hidden
            ContentUnavailableView {
                Label(String(localized: "No Cards"), systemImage: "creditcard")
            } description: {
                Text(String(localized: "All cards are expired. Toggle 'Show Expired' in the sort menu to see them."))
            }
        } else if allCards.isEmpty {
            // First launch - no cards at all
            EmptyCardListView {
                showingAddOptions = true
            }
        } else {
            // Fallback
            ContentUnavailableView {
                Label(String(localized: "No Cards"), systemImage: "creditcard")
            } description: {
                Text(String(localized: "Add your first loyalty card"))
            } actions: {
                Button(String(localized: "Add Card")) {
                    showingAddOptions = true
                }
                .buttonStyle(.borderedProminent)
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
        Button(action: { showingAddOptions = true }) {
            Label(String(localized: "Add Card"), systemImage: "plus")
        }
        .accessibilityIdentifier("addCardButton")
    }

    private var addOptionsSheet: some View {
        VStack(spacing: 16) {
            Text(String(localized: "Add Card"))
                .font(.headline)
                .padding(.top, 8)

            if BarcodeScannerView.isSupported {
                Button {
                    showingAddOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showingBarcodeScanner = true
                    }
                } label: {
                    Label(String(localized: "Scan Barcode"), systemImage: "barcode.viewfinder")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 46)
                }
                .buttonStyle(.borderedProminent)
            } else {
                Button {
                    showingAddOptions = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                        showingCamera = true
                    }
                } label: {
                    Label(String(localized: "Take a Photo"), systemImage: "camera")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .frame(minHeight: 46)
                }
                .buttonStyle(.borderedProminent)
            }

            Button {
                showingAddOptions = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showingPhotoPicker = true
                }
            } label: {
                Label(String(localized: "Choose from Library"), systemImage: "photo.on.rectangle")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 46)
            }
            .buttonStyle(.borderedProminent)

            Button {
                clearScannedState()
                isProcessingQuickScan = false
                showingAddOptions = false
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    showingEditor = true
                }
            } label: {
                Label(String(localized: "Add Manually"), systemImage: "square.and.pencil")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .frame(minHeight: 46)
            }
            .accessibilityIdentifier("addManuallyButton")
            .buttonStyle(.bordered)

            Button(String(localized: "Cancel"), role: .cancel) {
                showingAddOptions = false
            }
            .accessibilityIdentifier("addOptionsCancelButton")
            .padding(.top, 4)
        }
        .padding(.horizontal, 20)
        .presentationDetents([.height(320)])
    }

    private var quickScanProgressOverlay: some View {
        ZStack {
            Color.black.opacity(0.2)
                .ignoresSafeArea()

            VStack(spacing: 10) {
                ProgressView()
                Text(String(localized: "Scanning..."))
                    .font(.subheadline)
            }
            .padding(.vertical, 14)
            .padding(.horizontal, 18)
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
    
    private func toggleFavorite(_ card: LoyaltyCard) {
        withAnimation {
            card.isFavorite.toggle()
        }
    }
    
    private func shareCard(_ card: LoyaltyCard) {
        do {
            let fileURL = try CardExporter.createShareFile(for: card)
            shareItem = ShareItem(url: fileURL)
        } catch {
            errorAlert = .shareFailed(error)
        }
    }
    
    private func confirmDeleteCards(offsets: IndexSet) {
        // For swipe-to-delete, we only handle single card deletion with confirmation
        if let index = offsets.first {
            cardToDelete = filteredAndSortedCards[index]
            showingDeleteConfirmation = true
        }
    }
    
    private func deleteCard(_ card: LoyaltyCard) {
        withAnimation {
            CardRepository(modelContext: modelContext).delete(card)
        }
    }
    
    private func dismissActivePresentation() {
        displayCard = nil
        showingSettings = false
        showingAddOptions = false
        showingCamera = false
        showingBarcodeScanner = false
        showingEditor = false
        isProcessingQuickScan = false
        selectedCard = nil
        showingAlwaysPrompt = false
        shareItem = nil
        showingImportPreview = false
        importContainer = nil
        clearScannedState()
    }

    private func handleFileImport(_ url: URL) {
        do {
            guard url.startAccessingSecurityScopedResource() else {
                return
            }
            defer { url.stopAccessingSecurityScopedResource() }
            
            let data = try Data(contentsOf: url)
            let container = try CardImporter.importFromData(data)
            
            importContainer = container
            showingImportPreview = true
            
        } catch {
            errorAlert = .importFailed(error)
        }
    }
    
    private func handleDeepLink(_ url: URL) {
        switch CardListDeepLink(url: url) {
        case .card(let cardID):
            if let card = allCards.first(where: { $0.id == cardID }) {
                displayCard = card
            }

        case .nearbyCards(let cardIDs):
            if let card = allCards.first(where: { cardIDs.contains($0.id) }) {
                displayCard = card
            }

        case .unsupported:
            break
        }
    }
    
    @MainActor
    private func importCards(container: CardExportContainer, strategy: CardImporter.ImportStrategy) async throws -> CardImporter.ImportResult {
        try CardRepository(modelContext: modelContext).importCards(from: container, strategy: strategy)
    }
    
    private func clearScannedState() {
        scannedBarcodeData = nil
        scannedBarcodeType = nil
        scannedColor = nil
        scannedSuggestedColors = []
    }

    private func requestOpenExistingCardEditor(cardID: UUID) {
        pendingOpenExistingCardID = cardID
        showingEditor = false
        selectedCard = nil
        presentPendingExistingCardEditorIfNeeded()
    }

    private func presentPendingExistingCardEditorIfNeeded() {
        guard !showingEditor, selectedCard == nil else {
            return
        }
        guard let pendingCardID = pendingOpenExistingCardID else {
            return
        }
        guard let targetCard = allCards.first(where: { $0.id == pendingCardID }) else {
            pendingOpenExistingCardID = nil
            return
        }

        pendingOpenExistingCardID = nil
        selectedCard = targetCard
    }

    @MainActor
    private func handleScannerResult(barcode: ScannedBarcode, photo: UIImage?) {
        clearScannedState()
        showingBarcodeScanner = false

        scannedBarcodeData = barcode.data
        scannedBarcodeType = BarcodeType(from: barcode.symbology)

        if let photo {
            let analysis = DominantColorExtractor.analyzeColors(from: photo)
            scannedColor = analysis.confidence >= 0.12 ? analysis.primaryColor : nil
            scannedSuggestedColors = analysis.suggestedColors
        }

        showingEditor = true
    }

    @MainActor
    private func processImage(_ image: UIImage) {
        clearScannedState()
        isProcessingQuickScan = true

        Task {
            var foundBarcode = false

            // Run barcode scan — failure is acceptable
            if let matches = try? await BarcodeImageScanner.scan(from: image),
               let preferred = BarcodeImageScanner.preferredMatch(from: matches) {
                scannedBarcodeData = preferred.data
                scannedBarcodeType = preferred.type
                foundBarcode = true
            }

            // Run color extraction with confidence + suggestions.
            let analysis = DominantColorExtractor.analyzeColors(from: image)
            scannedColor = analysis.confidence >= 0.12 ? analysis.primaryColor : nil
            scannedSuggestedColors = analysis.suggestedColors

            isProcessingQuickScan = false

            if foundBarcode {
                showingEditor = true
            } else {
                photoPickerScanFailed = true
            }
        }
    }

    @MainActor
    private func processImageData(_ imageData: Data) {
        isProcessingQuickScan = true
        if let image = UIImage(data: imageData) {
            processImage(image)
        } else {
            clearScannedState()
            isProcessingQuickScan = false
            showingEditor = true
        }
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

struct CardListErrorAlert: Identifiable {
    let id = UUID()
    let title: String
    let message: String

    static func shareFailed(_ error: Error) -> CardListErrorAlert {
        CardListErrorAlert(
            title: String(localized: "Export Failed"),
            message: error.localizedDescription
        )
    }

    static func importFailed(_ error: Error) -> CardListErrorAlert {
        CardListErrorAlert(
            title: String(localized: "Import Failed"),
            message: error.localizedDescription
        )
    }
}

enum CardListDeepLink {
    case card(UUID)
    case nearbyCards([UUID])
    case unsupported

    init(url: URL) {
        guard let host = url.host,
              let components = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let queryItems = components.queryItems else {
            self = .unsupported
            return
        }

        switch host {
        case "card":
            guard let idString = queryItems.first(where: { $0.name == "id" })?.value,
                  let cardID = UUID(uuidString: idString) else {
                self = .unsupported
                return
            }
            self = .card(cardID)

        case "nearby-cards":
            guard let idsValue = queryItems.first(where: { $0.name == "ids" })?.value else {
                self = .unsupported
                return
            }
            let ids = idsValue
                .split(separator: ",")
                .compactMap { UUID(uuidString: String($0)) }
            guard !ids.isEmpty else {
                self = .unsupported
                return
            }
            self = .nearbyCards(ids)

        default:
            self = .unsupported
        }
    }
}

#Preview {
    CardListView()
        .modelContainer(for: LoyaltyCard.self, inMemory: true)
}

//
//  DataSettingsView.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
struct DataSettingsView: View {
    @Query private var allCards: [LoyaltyCard]
    @Environment(\.modelContext) private var modelContext

    @State private var syncSnapshot = SyncStatusSnapshot(
        status: .unavailable,
        lastCheckedAt: SharedDataManager.getLastSyncCheckDate()
    )
    @State private var shareItem: ShareItem?
    @State private var exportError: Error?
    @State private var showExportError = false

    @State private var showingFilePicker = false
    @State private var importContainer: CardExportContainer?
    @State private var showingImportPreview = false
    @State private var importError: Error?
    @State private var showImportError = false

    private struct ShareItem: Identifiable {
        let id = UUID()
        let url: URL
    }

    var body: some View {
        List {
            // Export
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "iCloud Sync", comment: "Label for iCloud sync status row in data settings."))
                        Text(syncStatusTitle)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        if let lastCheckedAt = syncSnapshot.lastCheckedAt {
                            HStack(spacing: 4) {
                                Text(String(localized: "Last checked", comment: "Label preceding the relative time of last sync check."))
                                Text(lastCheckedAt, style: .relative)
                            }
                            .font(.caption2)
                            .foregroundStyle(.tertiary)
                        }
                    }
                    Spacer()
                    Button {
                        Task {
                            await refreshSyncStatus()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .accessibilityLabel(String(localized: "Refresh Sync Status", comment: "Accessibility label for the refresh sync status button."))
                }
                .accessibilityIdentifier("iCloudSyncStatusRow")

                Button {
                    exportAllCards()
                } label: {
                    HStack {
                        Text(String(localized: "Export All Cards", comment: "Button to export all loyalty cards at once."))
                        Spacer()
                        Text("\(allCards.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(allCards.isEmpty)

                NavigationLink {
                    CardExportSelectionView()
                } label: {
                    Text(String(localized: "Select Cards to Export", comment: "Button to choose specific cards for export."))
                }
                .accessibilityIdentifier("selectCardsToExportRow")
                .disabled(allCards.isEmpty)
            } header: {
                Text(String(localized: "Export", comment: "Section header for card export options."))
            } footer: {
                Text(String(localized: "Cards are exported as .kartonche files that can be shared and imported on other devices.", comment: "Footer explaining the export file format."))
            }

            // Import
            Section {
                Button {
                    showingFilePicker = true
                } label: {
                    Text(String(localized: "Import from File", comment: "Button to import cards from a .kartonche file."))
                }
            } header: {
                Text(String(localized: "Import", comment: "Section header for card import options."))
            }
        }
        .navigationTitle(String(localized: "Data", comment: "Navigation title for the data settings screen."))
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await refreshSyncStatus()
        }
        .fileImporter(
            isPresented: $showingFilePicker,
            allowedContentTypes: [.kartonche]
        ) { result in
            handleFileImportResult(result)
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
        .alert(String(localized: "Export Failed", comment: "Alert title when card export fails."), isPresented: $showExportError) {
            Button(String(localized: "OK", comment: "Dismiss button on the export error alert.")) {}
        } message: {
            if let error = exportError {
                Text(error.localizedDescription)
            }
        }
        .alert(String(localized: "Import Failed", comment: "Alert title when card import fails."), isPresented: $showImportError) {
            Button(String(localized: "OK", comment: "Dismiss button on the import error alert.")) {}
        } message: {
            if let error = importError {
                Text(error.localizedDescription)
            }
        }
    }

    private func exportAllCards() {
        do {
            let data = try CardExporter.exportCards(allCards)
            let fileName = CardExporter.generateFileName(cardCount: allCards.count)
            let fileURL = try CardExporter.createTemporaryFile(from: data, fileName: fileName)
            shareItem = ShareItem(url: fileURL)
        } catch {
            exportError = error
            showExportError = true
        }
    }

    private func handleFileImportResult(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            do {
                guard url.startAccessingSecurityScopedResource() else { return }
                defer { url.stopAccessingSecurityScopedResource() }

                let data = try Data(contentsOf: url)
                let container = try CardImporter.importFromData(data)

                importContainer = container
                showingImportPreview = true
            } catch {
                importError = error
                showImportError = true
            }
        case .failure(let error):
            importError = error
            showImportError = true
        }
    }

    @MainActor
    private func importCards(container: CardExportContainer, strategy: CardImporter.ImportStrategy) async throws -> CardImporter.ImportResult {
        try CardRepository(modelContext: modelContext).importCards(from: container, strategy: strategy)
    }

    @MainActor
    private func refreshSyncStatus() async {
        syncSnapshot = await SyncStatusService().refreshStatus()
    }

    private var syncStatusTitle: String {
        switch syncSnapshot.status {
        case .active:
            return String(localized: "Sync Active", comment: "Status text when iCloud sync is working.")
        case .signedOut:
            return String(localized: "iCloud Signed Out", comment: "Status text when user is signed out of iCloud.")
        case .unavailable:
            return String(localized: "iCloud Unavailable", comment: "Status text when iCloud is not available on the device.")
        case .error:
            return String(localized: "Sync Error", comment: "Status text when iCloud sync encountered an error.")
        }
    }
}

#Preview {
    NavigationStack {
        DataSettingsView()
            .modelContainer(for: LoyaltyCard.self, inMemory: true)
    }
}

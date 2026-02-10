//
//  DataSettingsView.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import SwiftUI
import SwiftData
import UniformTypeIdentifiers
import WidgetKit

struct DataSettingsView: View {
    @Query private var allCards: [LoyaltyCard]
    @Environment(\.modelContext) private var modelContext

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
                Button {
                    exportAllCards()
                } label: {
                    HStack {
                        Text(String(localized: "Export All Cards"))
                        Spacer()
                        Text("\(allCards.count)")
                            .foregroundStyle(.secondary)
                    }
                }
                .disabled(allCards.isEmpty)

                NavigationLink {
                    CardExportSelectionView()
                } label: {
                    Text(String(localized: "Select Cards to Export"))
                }
                .disabled(allCards.isEmpty)
            } header: {
                Text(String(localized: "Export"))
            } footer: {
                Text(String(localized: "Cards are exported as .kartonche files that can be shared and imported on other devices."))
            }

            // Import
            Section {
                Button {
                    showingFilePicker = true
                } label: {
                    Text(String(localized: "Import from File"))
                }
            } header: {
                Text(String(localized: "Import"))
            }
        }
        .navigationTitle(String(localized: "Data"))
        .navigationBarTitleDisplayMode(.inline)
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
                    existingCards: allCards,
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
        .alert(String(localized: "Export Failed"), isPresented: $showExportError) {
            Button(String(localized: "OK")) {}
        } message: {
            if let error = exportError {
                Text(error.localizedDescription)
            }
        }
        .alert(String(localized: "Import Failed"), isPresented: $showImportError) {
            Button(String(localized: "OK")) {}
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
        let result = try CardImporter.importCards(
            from: container,
            into: modelContext,
            strategy: strategy
        )

        if result.hasChanges {
            WidgetCenter.shared.reloadAllTimelines()
        }

        return result
    }
}

#Preview {
    NavigationStack {
        DataSettingsView()
            .modelContainer(for: LoyaltyCard.self, inMemory: true)
    }
}

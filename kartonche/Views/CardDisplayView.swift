//
//  CardDisplayView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers

/// Full-screen view for displaying a loyalty card barcode
struct CardDisplayView: View {
    let card: LoyaltyCard
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var brightnessManager = BrightnessManager()
    @StateObject private var screenManager = ScreenManager()
    @State private var screen: UIScreen?
    @State private var shareItem: ShareItem?
    @State private var isNotesExpanded: Bool = false
    
    var body: some View {
        let primaryColor = card.color.flatMap { Color(hex: $0) } ?? Color.accentColor
        let secondaryColor = card.secondaryColor.flatMap { Color(hex: $0) } ?? primaryColor.contrastingTextColor()
        
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Colored header with card info
                ZStack(alignment: .topTrailing) {
                    VStack(spacing: 8) {
                        Text(card.storeName)
                            .font(.title3)
                            .fontWeight(.semibold)
                        
                        Text(card.name)
                            .font(.title2)
                            .fontWeight(.bold)
                        
                        if !card.cardNumber.isEmpty {
                            Text(card.cardNumber)
                                .font(.caption)
                        }
                    }
                    .foregroundStyle(secondaryColor)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 24)
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(card.name), \(card.storeName)" + (card.cardNumber.isEmpty ? "" : ", " + String(localized: "card number") + " \(card.cardNumber)"))
                    
                    // Share button in top right
                    Button {
                        shareCard()
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                            .font(.title2)
                            .foregroundStyle(secondaryColor)
                            .padding(16)
                    }
                    .accessibilityLabel(String(localized: "Share card"))
                }
                .background(primaryColor)
                
                Spacer()
                
                // White section with barcode
                BarcodeImageView(
                    data: card.barcodeData,
                    type: card.barcodeType
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                .accessibilityLabel(String(localized: "Barcode for scanning"))
                .accessibilityValue("\(card.barcodeType.displayName), \(card.barcodeData)")
                .accessibilityHint(String(localized: "Show this to the cashier to scan"))
                
                Spacer()
                
                // Collapsible notes section (only if notes exist)
                if let notes = card.notes, !notes.isEmpty {
                    DisclosureGroup(isExpanded: $isNotesExpanded) {
                        Text(notes)
                            .font(.body)
                            .foregroundStyle(.primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.top, 8)
                    } label: {
                        Label(String(localized: "Notes"), systemImage: "note.text")
                            .foregroundStyle(primaryColor)
                    }
                    .tint(primaryColor)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 16)
                }
                
                // Colored close button
                Button(action: { dismiss() }) {
                    Text(String(localized: "Close"))
                        .font(.headline)
                        .foregroundStyle(secondaryColor)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(primaryColor)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .background(ScreenAccessor(screen: $screen))
        .onAppear {
            updateLastUsedDate()
            screenManager.preventSleep()
        }
        .onChange(of: screen) { _, newScreen in
            if let newScreen = newScreen {
                brightnessManager.increaseForBarcode(screen: newScreen)
            }
        }
        .onDisappear {
            brightnessManager.restore()
            screenManager.restoreIdleTimer()
        }
        .sheet(item: $shareItem) { item in
            ActivityViewController(activityItems: [item.url])
                .ignoresSafeArea()
        }
    }
    
    private func shareCard() {
        do {
            let data = try CardExporter.exportCard(card)
            let fileName = CardExporter.generateFileName(cardCount: 1, cardName: card.name)
            let fileURL = try CardExporter.createTemporaryFile(from: data, fileName: fileName)
            
            shareItem = ShareItem(url: fileURL)
        } catch {
            // TODO: Show error alert
            print("Failed to export card: \(error)")
        }
    }
    
    struct ShareItem: Identifiable {
        let id = UUID()
        let url: URL
    }
    
    private func updateLastUsedDate() {
        card.lastUsedDate = Date()
    }
}

/// UIViewRepresentable helper to access UIScreen from SwiftUI
private struct ScreenAccessor: UIViewRepresentable {
    @Binding var screen: UIScreen?
    
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            self.screen = view.window?.windowScene?.screen
        }
        return view
    }
    
    func updateUIView(_ uiView: UIView, context: Context) {
        DispatchQueue.main.async {
            self.screen = uiView.window?.windowScene?.screen
        }
    }
}

/// UIActivityViewController wrapper for SwiftUI
struct ActivityViewController: UIViewControllerRepresentable {
    let activityItems: [Any]
    
    func makeUIViewController(context: Context) -> UIActivityViewController {
        let controller = UIActivityViewController(
            activityItems: activityItems,
            applicationActivities: nil
        )
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // No updates needed
    }
}

#Preview("Without notes") {
    CardDisplayView(
        card: LoyaltyCard(
            name: "Billa Club",
            storeName: "Billa",
            cardNumber: "1234567890123",
            barcodeType: .ean13,
            barcodeData: "1234567890123",
            color: "#FF0000"
        )
    )
}

#Preview("With notes") {
    let card = LoyaltyCard(
        name: "Billa Club",
        storeName: "Billa",
        cardNumber: "1234567890123",
        barcodeType: .ean13,
        barcodeData: "1234567890123",
        color: "#FF0000"
    )
    card.notes = "Use this card for 5% discount on Fridays. Ask cashier about bonus points."
    return CardDisplayView(card: card)
}

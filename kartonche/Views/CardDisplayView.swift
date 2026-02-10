//
//  CardDisplayView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import UIKit
import UniformTypeIdentifiers
import PassKit

/// Full-screen view for displaying a loyalty card barcode
struct CardDisplayView: View {
    let card: LoyaltyCard
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var brightnessManager = BrightnessManager()
    @StateObject private var screenManager = ScreenManager()
    @State private var screen: UIScreen?
    @State private var shareItem: ShareItem?
    @State private var barcodeAppeared: Bool = false
    @State private var showNotesSheet: Bool = false
    @State private var isGeneratingPass = false
    @State private var passError: String?
    @State private var passToAdd: PKPass?
    
    var body: some View {
        let primaryColor = card.color.flatMap { Color(hex: $0) } ?? Color.accentColor
        let secondaryColor = card.secondaryColor.flatMap { Color(hex: $0) } ?? primaryColor.contrastingTextColor()
        
        ZStack {
            // Colored blur background
            primaryColor.opacity(0.2)
                .blur(radius: 60)
                .ignoresSafeArea()
                .opacity(barcodeAppeared ? 1 : 0)
            
            VStack(spacing: 0) {
                // Colored header
                headerView(primaryColor: primaryColor, secondaryColor: secondaryColor)
                
                Spacer(minLength: 40)
                
                // Floating barcode card
                barcodeCardView(primaryColor: primaryColor)
                    .scaleEffect(barcodeAppeared ? 1.0 : 0.95)
                    .opacity(barcodeAppeared ? 1.0 : 0.0)
                
                Spacer(minLength: 40)

                // Add to Apple Wallet button
                if card.barcodeType.supportsAppleWallet && !isPassInWallet {
                    if isGeneratingPass {
                        ProgressView(String(localized: "Generating pass..."))
                            .padding(.bottom, 12)
                    } else {
                        AddToWalletButton {
                            generateAndAddPass()
                        }
                        .frame(width: 250, height: 48)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                        .accessibilityLabel(String(localized: "Add to Apple Wallet"))
                        .padding(.bottom, 32)
                    }
                }

                // Notes button (if notes exist)
                if let notes = card.notes, !notes.isEmpty {
                    Button {
                        showNotesSheet = true
                    } label: {
                        Label(String(localized: "Notes"), systemImage: "note.text")
                            .font(.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(primaryColor)
                    }
                    .padding(.bottom, 20)
                }
            }
            
        }
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    if gesture.translation.height > 100 {
                        dismiss()
                    }
                }
        )
        .sheet(isPresented: $showNotesSheet) {
            notesSheetView
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
        .background(ScreenAccessor(screen: $screen))
        .onAppear {
            updateLastUsedDate()
            screenManager.preventSleep()
            withAnimation(.easeIn(duration: 0.4)) {
                // Background appears
            }
            withAnimation(.spring(duration: 0.5).delay(0.2)) {
                barcodeAppeared = true
            }
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
        .sheet(item: $passToAdd) { pass in
            AddPassViewController(pass: pass) {
                passToAdd = nil
            }
        }
        .alert(String(localized: "Failed to create pass"), isPresented: Binding(
            get: { passError != nil },
            set: { if !$0 { passError = nil } }
        )) {
            Button(String(localized: "OK"), role: .cancel) {}
        } message: {
            if let passError {
                Text(passError)
            }
        }
    }
    
    private func headerView(primaryColor: Color, secondaryColor: Color) -> some View {
        HStack(spacing: 16) {
            // Card info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.storeName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(secondaryColor)
                
                Text(card.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(secondaryColor)
                
                if !card.cardNumber.isEmpty {
                    Text(card.cardNumber)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(secondaryColor.opacity(0.8))
                }
            }
            
            Spacer()
            
            // Action buttons
            HStack(spacing: 16) {
                // Share button
                Button {
                    shareCard()
                } label: {
                    Image(systemName: "square.and.arrow.up")
                        .font(.title2)
                        .foregroundStyle(secondaryColor)
                }
                .accessibilityLabel(String(localized: "Share card"))
                
                // Close button
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .font(.title2)
                        .foregroundStyle(secondaryColor)
                }
                .accessibilityLabel(String(localized: "Close"))
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(primaryColor)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(card.name), \(card.storeName)" + (card.cardNumber.isEmpty ? "" : ", " + String(localized: "card number") + " \(card.cardNumber)"))
    }
    
    private func barcodeCardView(primaryColor: Color) -> some View {
        BarcodeImageView(
            data: card.barcodeData,
            type: card.barcodeType
        )
        .frame(maxWidth: .infinity, maxHeight: 300)
        .padding(.horizontal, 32)
        .padding(.vertical, 24)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.white)
                .shadow(color: primaryColor.opacity(0.4), radius: 30, x: 0, y: 15)
                .shadow(color: primaryColor.opacity(0.2), radius: 15, x: 0, y: 8)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        )
        .padding(.horizontal, 24)
        .accessibilityLabel(String(localized: "Barcode for scanning"))
        .accessibilityValue("\(card.barcodeType.displayName), \(card.barcodeData)")
        .accessibilityHint(String(localized: "Show this to the cashier to scan"))
    }
    
    private var notesSheetView: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    Text(card.notes ?? "")
                        .font(.body)
                        .foregroundStyle(.primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .navigationTitle(String(localized: "Notes"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(String(localized: "Done")) {
                        showNotesSheet = false
                    }
                }
            }
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
    
    private var isPassInWallet: Bool {
        PKPassLibrary().passes().contains {
            $0.serialNumber == card.id.uuidString &&
            $0.passTypeIdentifier == WalletPassConfiguration.passTypeIdentifier
        }
    }

    private func generateAndAddPass() {
        isGeneratingPass = true
        passError = nil

        Task {
            do {
                let passData = try WalletPassGenerator.generate(for: card)
                let pass = try PKPass(data: passData)
                await MainActor.run {
                    isGeneratingPass = false
                    passToAdd = pass
                }
            } catch {
                await MainActor.run {
                    isGeneratingPass = false
                    passError = error.localizedDescription
                }
            }
        }
    }

    private func updateLastUsedDate() {
        card.lastUsedDate = Date()
    }
}

extension PKPass: @retroactive Identifiable {
    public var id: String { serialNumber }
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

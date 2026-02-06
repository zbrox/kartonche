//
//  CardDisplayView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI

/// Full-screen view for displaying a loyalty card barcode
struct CardDisplayView: View {
    let card: LoyaltyCard
    @Environment(\.dismiss) private var dismiss
    
    @StateObject private var brightnessManager = BrightnessManager()
    @StateObject private var screenManager = ScreenManager()
    @State private var screen: UIScreen?
    
    var body: some View {
        let primaryColor = card.color.flatMap { Color(hex: $0) } ?? Color.accentColor
        let secondaryColor = card.secondaryColor.flatMap { Color(hex: $0) } ?? Color.white
        
        ZStack {
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Colored header with card info
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
                .background(primaryColor)
                .accessibilityElement(children: .combine)
                .accessibilityLabel("\(card.name), \(card.storeName)" + (card.cardNumber.isEmpty ? "" : ", " + String(localized: "card number") + " \(card.cardNumber)"))
                
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

#Preview {
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

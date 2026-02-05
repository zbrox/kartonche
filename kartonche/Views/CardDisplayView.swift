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
    
    var body: some View {
        ZStack {
            // High contrast background
            Color.white
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                Spacer()
                
                // Card info
                VStack(spacing: 8) {
                    Text(card.name)
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundStyle(.black)
                    
                    Text(card.storeName)
                        .font(.title3)
                        .foregroundStyle(.gray)
                    
                    if !card.cardNumber.isEmpty {
                        Text(card.cardNumber)
                            .font(.caption)
                            .foregroundStyle(.gray)
                    }
                }
                
                // Barcode
                BarcodeImageView(
                    data: card.barcodeData,
                    type: card.barcodeType
                )
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 32)
                
                Spacer()
                
                // Dismiss button
                Button(action: { dismiss() }) {
                    Text(String(localized: "Close"))
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 32)
            }
        }
        .onAppear {
            updateLastUsedDate()
            brightnessManager.increaseForBarcode()
            screenManager.preventSleep()
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

//
//  CardPreviewView.swift
//  quicklook
//
//  Created on 2026-02-10.
//

import SwiftUI
import UIKit

struct CardPreviewView: View {
    let card: CardExportDTO
    
    private var primaryColor: Color {
        Color(hex: card.color) ?? .accentColor
    }
    
    private var secondaryColor: Color {
        if let hex = card.secondaryColor {
            return Color(hex: hex) ?? primaryColor.contrastingTextColor()
        }
        return primaryColor.contrastingTextColor()
    }
    
    private var barcodeImage: UIImage? {
        let result = BarcodeGenerator.generate(
            from: card.barcodeData,
            type: card.barcodeType,
            scale: 8.0
        )
        
        switch result {
        case .success(let image):
            return image
        case .failure:
            return nil
        }
    }
    
    private var hasLocations: Bool {
        !card.locations.isEmpty
    }
    
    var body: some View {
        ZStack {
            // Colored blur background
            primaryColor.opacity(0.2)
                .blur(radius: 60)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Colored header (matching CardDisplayView)
                headerView
                
                Spacer(minLength: 24)
                
                // Barcode card (matching CardDisplayView style)
                barcodeCardView
                
                Spacer(minLength: 24)
                
                // Location indicator
                if hasLocations {
                    HStack(spacing: 6) {
                        Image(systemName: "mappin.circle.fill")
                            .font(.footnote)
                        Text("locations_count_\(card.locations.count)")
                            .font(.footnote)
                    }
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 16)
                }
            }
        }
    }
    
    private var headerView: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let storeName = card.storeName, !storeName.isEmpty {
                Text(storeName)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(secondaryColor)
            }

            Text(card.name)
                .font(.title2.weight(.bold))
                .foregroundStyle(secondaryColor)

            if let cardNumber = card.cardNumber, !cardNumber.isEmpty {
                Text(cardNumber)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(secondaryColor.opacity(0.8))
            }

            if let cardholderName = card.cardholderName, !cardholderName.isEmpty {
                Text(cardholderName)
                    .font(.caption.weight(.medium))
                    .foregroundStyle(secondaryColor.opacity(0.7))
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 20)
        .padding(.vertical, 20)
        .background(primaryColor)
    }
    
    private var barcodeCardView: some View {
        Group {
            if let image = barcodeImage {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.none)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: 200)
            } else {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color.secondary.opacity(0.2))
                    .frame(height: 100)
                    .overlay {
                        Image(systemName: "barcode")
                            .font(.largeTitle)
                            .foregroundStyle(.secondary)
                    }
            }
        }
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
    }
}

#Preview {
    CardPreviewView(card: CardExportDTO(
        id: UUID(),
        name: "Club Card",
        storeName: "BILLA",
        cardNumber: "1234567890123",
        barcodeType: .ean13,
        barcodeData: "1234567890123",
        color: "#E31E26",
        secondaryColor: "#FFFFFF",
        notes: nil,
        cardholderName: nil,
        isFavorite: false,
        createdDate: Date(),
        lastUsedDate: nil,
        expirationDate: nil,
        cardImage: nil,
        locations: [
            LocationExportDTO(
                id: UUID(),
                name: "Mall Bulgaria",
                address: "bul. Aleksandar Stamboliyski 101",
                latitude: 42.6977,
                longitude: 23.3219,
                radius: 100
            )
        ]
    ))
}

#Preview("No locations") {
    CardPreviewView(card: CardExportDTO(
        id: UUID(),
        name: "Loyalty Card",
        storeName: "Kaufland",
        cardNumber: nil,
        barcodeType: .qr,
        barcodeData: "KAUF123456",
        color: "#CC0000",
        secondaryColor: nil,
        notes: nil,
        cardholderName: nil,
        isFavorite: false,
        createdDate: Date(),
        lastUsedDate: nil,
        expirationDate: nil,
        cardImage: nil,
        locations: []
    ))
}

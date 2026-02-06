//
//  CardRowView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI

/// Row view for displaying a loyalty card in the list
struct CardRowView: View {
    let card: LoyaltyCard
    let onFavoriteToggle: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator
            if let colorHex = card.color {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color(hex: colorHex) ?? .gray)
                    .frame(width: 4, height: 44)
            }
            
            // Card info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                
                Text(card.storeName)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                if !card.cardNumber.isEmpty {
                    Text(card.cardNumber)
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }
            
            Spacer()
            
            // Expiration indicator
            if let expirationDate = card.expirationDate {
                HStack(spacing: 4) {
                    Image(systemName: card.isExpired ? "exclamationmark.triangle.fill" : "calendar")
                        .font(.caption)
                    Text(formatShortDate(expirationDate))
                        .font(.caption)
                }
                .foregroundStyle(card.isExpired ? .red : (card.isExpiringSoon ? .orange : .secondary))
            }
            
            // Favorite star
            Button(action: onFavoriteToggle) {
                Image(systemName: card.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(card.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
        }
        .padding(.vertical, 4)
    }
    
    private func formatShortDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d.M.yy"
        return formatter.string(from: date)
    }
}

extension Color {
    /// Initialize Color from hex string
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let r = Double((rgb & 0xFF0000) >> 16) / 255.0
        let g = Double((rgb & 0x00FF00) >> 8) / 255.0
        let b = Double(rgb & 0x0000FF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    List {
        CardRowView(
            card: LoyaltyCard(
                name: "Billa Club",
                storeName: "Billa",
                cardNumber: "1234567890123",
                barcodeType: .ean13,
                barcodeData: "1234567890123",
                color: "#FF0000",
                isFavorite: true
            ),
            onFavoriteToggle: {}
        )
        
        CardRowView(
            card: LoyaltyCard(
                name: "Kaufland Card",
                storeName: "Kaufland",
                cardNumber: "9876543210",
                barcodeType: .qr,
                barcodeData: "9876543210",
                isFavorite: false
            ),
            onFavoriteToggle: {}
        )
    }
}

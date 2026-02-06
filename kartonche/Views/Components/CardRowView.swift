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
            // Color indicator (always show for consistent alignment)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: card.color) ?? .accentColor)
                .frame(width: 4, height: 44)
                .accessibilityHidden(true)
            
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
            .accessibilityElement(children: .combine)
            .accessibilityLabel(accessibilityCardLabel)
            
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
                .accessibilityElement(children: .combine)
                .accessibilityLabel(accessibilityExpirationLabel(expirationDate))
            }
            
            // Favorite star
            Button(action: onFavoriteToggle) {
                Image(systemName: card.isFavorite ? "star.fill" : "star")
                    .foregroundStyle(card.isFavorite ? .yellow : .gray)
            }
            .buttonStyle(.plain)
            .accessibilityLabel(card.isFavorite ? String(localized: "Remove from favorites") : String(localized: "Add to favorites"))
            .accessibilityAddTraits(.isButton)
        }
        .padding(.vertical, 4)
    }
    
    private var accessibilityCardLabel: String {
        var label = "\(card.name), \(card.storeName)"
        if !card.cardNumber.isEmpty {
            label += ", " + String(localized: "card number") + " \(card.cardNumber)"
        }
        return label
    }
    
    private func accessibilityExpirationLabel(_ date: Date) -> String {
        if card.isExpired {
            return String(localized: "Expired on") + " \(formatShortDate(date))"
        } else if card.isExpiringSoon {
            return String(localized: "Expiring soon on") + " \(formatShortDate(date))"
        } else {
            return String(localized: "Expires on") + " \(formatShortDate(date))"
        }
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

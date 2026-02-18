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
    let distance: Double? // Distance in meters (optional for nearby cards)
    let onFavoriteToggle: () -> Void
    
    init(card: LoyaltyCard, distance: Double? = nil, onFavoriteToggle: @escaping () -> Void) {
        self.card = card
        self.distance = distance
        self.onFavoriteToggle = onFavoriteToggle
    }
    
    var body: some View {
        HStack(spacing: 12) {
            // Color indicator (always show for consistent alignment)
            RoundedRectangle(cornerRadius: 4)
                .fill(Color(hex: card.color) ?? .accentColor)
                .frame(width: 4)
                .accessibilityHidden(true)
            
            // Card info
            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                
                HStack(spacing: 6) {
                    if let storeName = card.storeName, !storeName.isEmpty {
                        Text(storeName)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }

                    // Distance badge for nearby cards
                    if let distance = distance {
                        HStack(spacing: 2) {
                            Image(systemName: "location.fill")
                                .font(.caption2)
                            Text(formatDistance(distance))
                                .font(.caption2)
                        }
                        .foregroundStyle(.blue)
                    }
                }
                
                if let cardholderName = card.cardholderName, !cardholderName.isEmpty {
                    Text(cardholderName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                if let cardNumber = card.cardNumber, !cardNumber.isEmpty {
                    Text(cardNumber)
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
        var parts = [card.name]
        if let storeName = card.storeName, !storeName.isEmpty {
            parts.append(storeName)
        }
        if let cardholderName = card.cardholderName, !cardholderName.isEmpty {
            parts.append(cardholderName)
        }
        if let cardNumber = card.cardNumber, !cardNumber.isEmpty {
            parts.append(String(localized: "card number") + " \(cardNumber)")
        }
        return parts.joined(separator: ", ")
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
    
    private func formatDistance(_ meters: Double) -> String {
        if meters < 1000 {
            return "\(Int(meters))m"
        } else {
            let km = meters / 1000.0
            return String(format: "%.1fkm", km)
        }
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

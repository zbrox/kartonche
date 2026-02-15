//
//  MultiCardPreviewView.swift
//  quicklook
//
//  Created on 2026-02-10.
//

import SwiftUI

struct MultiCardPreviewView: View {
    let container: CardExportContainer

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 4) {
                Image(systemName: "creditcard.and.123")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)
                    .padding(.bottom, 4)

                Text(String(localized: "\(container.cards.count) Cards"))
                    .font(.title2.weight(.bold))

                Text(container.exportDate, style: .date)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 20)

            Divider()

            // Card list
            ScrollView {
                LazyVStack(spacing: 0) {
                    ForEach(container.cards) { card in
                        MultiCardRow(card: card)
                        if card.id != container.cards.last?.id {
                            Divider()
                                .padding(.leading, 28)
                        }
                    }
                }
            }
        }
    }
}

private struct MultiCardRow: View {
    let card: CardExportDTO

    var body: some View {
        HStack(spacing: 12) {
            RoundedRectangle(cornerRadius: 4)
                .fill(card.color.flatMap { Color(hex: $0) } ?? .accentColor)
                .frame(width: 4, height: 44)

            VStack(alignment: .leading, spacing: 4) {
                Text(card.name)
                    .font(.headline)
                if let storeName = card.storeName, !storeName.isEmpty {
                    Text(storeName)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                if let cardholderName = card.cardholderName, !cardholderName.isEmpty {
                    Text(cardholderName)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Text(card.barcodeType.rawValue.uppercased())
                .font(.caption2)
                .fontWeight(.semibold)
                .padding(.horizontal, 6)
                .padding(.vertical, 2)
                .background(.secondary.opacity(0.2))
                .cornerRadius(4)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
    }
}

#Preview {
    MultiCardPreviewView(container: CardExportContainer(cards: [
        CardExportDTO(
            id: UUID(), name: "Club Card", storeName: "BILLA",
            cardNumber: "1234567890123", barcodeType: .ean13,
            barcodeData: "1234567890123", color: "#E31E26",
            secondaryColor: "#FFFFFF", notes: nil, cardholderName: nil,
            isFavorite: false, createdDate: Date(), lastUsedDate: nil,
            expirationDate: nil, cardImage: nil, locations: []
        ),
        CardExportDTO(
            id: UUID(), name: "Loyalty Card", storeName: "Kaufland",
            cardNumber: "9876543210", barcodeType: .qr,
            barcodeData: "KAUF123456", color: "#CC0000",
            secondaryColor: nil, notes: nil, cardholderName: nil,
            isFavorite: false, createdDate: Date(), lastUsedDate: nil,
            expirationDate: nil, cardImage: nil, locations: []
        ),
        CardExportDTO(
            id: UUID(), name: "Fantastiko Card", storeName: "Fantastiko",
            cardNumber: "5555555555", barcodeType: .code128,
            barcodeData: "5555555555", color: "#00AA44",
            secondaryColor: nil, notes: nil, cardholderName: nil,
            isFavorite: false, createdDate: Date(), lastUsedDate: nil,
            expirationDate: nil, cardImage: nil, locations: []
        )
    ]))
}

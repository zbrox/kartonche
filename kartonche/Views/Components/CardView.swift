//
//  CardView.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import SwiftUI

/// Reusable card visual component that displays a card's barcode and information
struct CardView<Card: CardViewable>: View {
    let card: Card
    var showNotesButton: Bool = true
    var onClose: (() -> Void)? = nil
    
    @State private var showNotesSheet: Bool = false
    
    private var primaryColor: Color {
        card.color.flatMap { Color(hex: $0) } ?? Color.accentColor
    }
    
    private var secondaryColor: Color {
        card.secondaryColor.flatMap { Color(hex: $0) } ?? primaryColor.contrastingTextColor()
    }
    
    var body: some View {
        ZStack {
            primaryColor.opacity(0.2)
                .blur(radius: 60)
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                headerView
                
                Spacer(minLength: 40)
                
                barcodeCardView
                
                Spacer(minLength: 40)
                
                if showNotesButton, let notes = card.notes, !notes.isEmpty {
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
        .sheet(isPresented: $showNotesSheet) {
            notesSheetView
                .presentationDetents([.medium])
                .presentationDragIndicator(.visible)
        }
    }
    
    private var headerView: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                if let storeName = card.storeName, !storeName.isEmpty {
                    Text(storeName)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(secondaryColor)
                }

                Text(card.name)
                    .font(.title2.weight(.bold))
                    .foregroundStyle(secondaryColor)

                if !card.cardNumber.isEmpty {
                    Text(card.cardNumber)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(secondaryColor.opacity(0.8))
                }

                if let cardholderName = card.cardholderName, !cardholderName.isEmpty {
                    Text(cardholderName)
                        .font(.caption.weight(.medium))
                        .foregroundStyle(secondaryColor.opacity(0.7))
                }
            }

            Spacer()
            
            if let onClose = onClose {
                Button {
                    onClose()
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
        .accessibilityLabel(cardAccessibilityLabel)
    }
    
    private var cardAccessibilityLabel: String {
        var parts = [card.name]
        if let storeName = card.storeName, !storeName.isEmpty {
            parts.append(storeName)
        }
        if !card.cardNumber.isEmpty {
            parts.append(String(localized: "card number") + " \(card.cardNumber)")
        }
        if let cardholderName = card.cardholderName, !cardholderName.isEmpty {
            parts.append(cardholderName)
        }
        return parts.joined(separator: ", ")
    }

    private var barcodeCardView: some View {
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
}

#Preview("With close button") {
    CardView(
        card: PreviewCard(
            name: "Billa Club",
            storeName: "Billa",
            cardNumber: "1234567890123",
            barcodeType: .ean13,
            barcodeData: "1234567890123",
            color: "#FF0000",
            notes: "Sample notes"
        ),
        onClose: { }
    )
}

#Preview("Without close button") {
    CardView(
        card: PreviewCard(
            name: "Kaufland Card",
            storeName: "Kaufland",
            cardNumber: "9876543210",
            barcodeType: .code128,
            barcodeData: "9876543210",
            color: "#0066CC"
        )
    )
}

/// Preview helper struct conforming to CardViewable
private struct PreviewCard: CardViewable {
    let name: String
    let storeName: String?
    let cardNumber: String
    let barcodeType: BarcodeType
    let barcodeData: String
    let color: String?
    let secondaryColor: String?
    let notes: String?
    let cardholderName: String?

    init(
        name: String,
        storeName: String? = nil,
        cardNumber: String,
        barcodeType: BarcodeType,
        barcodeData: String,
        color: String? = nil,
        secondaryColor: String? = nil,
        notes: String? = nil,
        cardholderName: String? = nil
    ) {
        self.name = name
        self.storeName = storeName
        self.cardNumber = cardNumber
        self.barcodeType = barcodeType
        self.barcodeData = barcodeData
        self.color = color
        self.secondaryColor = secondaryColor
        self.notes = notes
        self.cardholderName = cardholderName
    }
}

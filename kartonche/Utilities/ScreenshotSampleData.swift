//
//  ScreenshotSampleData.swift
//  kartonche
//

import Foundation
import SwiftData

enum ScreenshotSampleData {
    static func seed(into context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<LoyaltyCard>())) ?? 0
        guard existing == 0 else { return }

        let cards = [
            LoyaltyCard(
                name: String(localized: "Morning Brew Coffee", comment: "Screenshot sample card name"),
                barcodeType: .qr,
                barcodeData: "MORNINGBREW-2024-LOYALTY-7892",
                color: "#6D4C41",
                secondaryColor: "#EFEBE9",
                isFavorite: true
            ),
            LoyaltyCard(
                name: String(localized: "Fresh Market", comment: "Screenshot sample card name"),
                barcodeType: .code128,
                barcodeData: "FM-884210-MEMBER",
                color: "#388E3C",
                secondaryColor: "#E8F5E9"
            ),
            LoyaltyCard(
                name: String(localized: "City Library", comment: "Screenshot sample card name"),
                cardNumber: "LIB-20260315-0042",
                barcodeType: .pdf417,
                barcodeData: "CITYLIB-PATRON-20260315-004271-ACTIVE",
                color: "#1565C0",
                secondaryColor: "#E3F2FD",
                cardholderName: String(localized: "Maria Ivanova", comment: "Screenshot sample cardholder name")
            ),
            LoyaltyCard(
                name: String(localized: "Downtown Gym", comment: "Screenshot sample card name"),
                barcodeType: .aztec,
                barcodeData: "DTGYM-M-9183-2026",
                color: "#E65100",
                secondaryColor: "#FFF3E0",
                expirationDate: Calendar.current.date(byAdding: .month, value: 3, to: Date())
            ),
            LoyaltyCard(
                name: String(localized: "Pet Paradise", comment: "Screenshot sample card name"),
                cardNumber: "4815162342130",
                barcodeType: .ean13,
                barcodeData: "4815162342130",
                color: "#00897B",
                secondaryColor: "#E0F2F1",
                notes: String(localized: "10% off on Tuesdays for premium members", comment: "Screenshot sample card notes")
            ),
        ]

        for card in cards {
            context.insert(card)
        }

        // Add a location to Fresh Market for the location screenshot
        let freshMarket = cards[1]
        let location = CardLocation(
            name: String(localized: "Fresh Market - Downtown", comment: "Screenshot sample location name"),
            address: String(localized: "42 Market Street", comment: "Screenshot sample location address"),
            latitude: 42.6977,
            longitude: 23.3219,
            radius: 500.0
        )
        location.card = freshMarket
        context.insert(location)

        try? context.save()
    }
}

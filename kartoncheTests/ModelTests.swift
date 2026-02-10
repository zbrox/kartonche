//
//  ModelTests.swift
//  kartoncheTests
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import Testing
import SwiftData
@testable import kartonche

@MainActor
struct ModelTests {
    
    @Test func barcodeTypeDisplayNames() {
        #expect(BarcodeType.qr.displayName == "QR Code")
        #expect(BarcodeType.code128.displayName == "Code 128")
        #expect(BarcodeType.ean13.displayName == "EAN-13")
        #expect(BarcodeType.pdf417.displayName == "PDF417")
        #expect(BarcodeType.aztec.displayName == "Aztec")
    }
    
    @Test func barcodeTypeCaseIterable() {
        let allCases = BarcodeType.allCases
        #expect(allCases.count == 5)
        #expect(allCases.contains(.qr))
        #expect(allCases.contains(.code128))
        #expect(allCases.contains(.ean13))
        #expect(allCases.contains(.pdf417))
        #expect(allCases.contains(.aztec))
    }
    
    @Test func loyaltyCardInitialization() {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Test Store",
            cardNumber: "1234567890",
            barcodeType: .qr,
            barcodeData: "1234567890"
        )
        
        #expect(card.name == "Test Card")
        #expect(card.storeName == "Test Store")
        #expect(card.cardNumber == "1234567890")
        #expect(card.barcodeType == .qr)
        #expect(card.barcodeData == "1234567890")
        #expect(card.isFavorite == false)
        #expect(card.color == nil)
        #expect(card.notes == nil)
        #expect(card.lastUsedDate == nil)
        #expect(card.cardImage == nil)
    }
    
    @Test func loyaltyCardWithOptionalFields() {
        let card = LoyaltyCard(
            name: "Premium Card",
            storeName: "Premium Store",
            cardNumber: "9876543210",
            barcodeType: .ean13,
            barcodeData: "9876543210",
            color: "#FF0000",
            notes: "VIP member",
            isFavorite: true
        )
        
        #expect(card.color == "#FF0000")
        #expect(card.notes == "VIP member")
        #expect(card.isFavorite == true)
    }
}

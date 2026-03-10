//
//  ModelTests.swift
//  kartoncheTests
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import Testing
import Foundation
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
        #expect(allCases.count == 10)
        #expect(allCases.contains(.qr))
        #expect(allCases.contains(.code128))
        #expect(allCases.contains(.ean13))
        #expect(allCases.contains(.pdf417))
        #expect(allCases.contains(.aztec))
        #expect(allCases.contains(.code39))
        #expect(allCases.contains(.upcE))
        #expect(allCases.contains(.interleaved2of5))
        #expect(allCases.contains(.dataMatrix))
        #expect(allCases.contains(.ean8))
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
        #expect(card.cardholderName == nil)
        #expect(card.lastUsedDate == nil)
        #expect(card.lastModifiedDate == nil)
        #expect(card.cardImage == nil)
    }

    @Test func loyaltyCardWithNilStoreName() {
        let card = LoyaltyCard(
            name: "Test Card",
            cardNumber: "1234567890",
            barcodeType: .qr,
            barcodeData: "1234567890"
        )

        #expect(card.storeName == nil)
    }

    @Test func loyaltyCardWithCardholderName() {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Test Store",
            cardNumber: "1234567890",
            barcodeType: .qr,
            barcodeData: "1234567890",
            cardholderName: "John Doe"
        )

        #expect(card.cardholderName == "John Doe")
    }
    
    @Test func cardExportDTORoundTripsCardholderName() {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Test Store",
            cardNumber: "1234567890",
            barcodeType: .qr,
            barcodeData: "1234567890",
            cardholderName: "Jane Doe"
        )

        let dto = CardExportDTO(from: card)
        #expect(dto.cardholderName == "Jane Doe")
        #expect(dto.storeName == "Test Store")
    }

    @Test func cardExportDTORoundTripsNilStoreName() {
        let card = LoyaltyCard(
            name: "Test Card",
            cardNumber: "1234567890",
            barcodeType: .qr,
            barcodeData: "1234567890"
        )

        let dto = CardExportDTO(from: card)
        #expect(dto.storeName == nil)
        #expect(dto.cardholderName == nil)
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

    @Test func lastModifiedDateSetOnCreation() {
        let now = Date()
        let card = LoyaltyCard(
            name: "Test Card",
            barcodeType: .qr,
            barcodeData: "123",
            lastModifiedDate: now
        )

        #expect(card.lastModifiedDate == now)
    }

    @Test func lastModifiedDateUpdatedOnEdit() {
        let card = LoyaltyCard(
            name: "Test Card",
            barcodeType: .qr,
            barcodeData: "123"
        )
        #expect(card.lastModifiedDate == nil)

        let editDate = Date()
        card.lastModifiedDate = editDate
        #expect(card.lastModifiedDate == editDate)
    }

    @Test func cardExportDTORoundTripsLastModifiedDate() {
        let now = Date()
        let card = LoyaltyCard(
            name: "Test Card",
            barcodeType: .qr,
            barcodeData: "123",
            lastModifiedDate: now
        )

        let dto = CardExportDTO(from: card)
        #expect(dto.lastModifiedDate == now)
    }

    @Test func cardExportDTORoundTripsNilLastModifiedDate() {
        let card = LoyaltyCard(
            name: "Test Card",
            barcodeType: .qr,
            barcodeData: "123"
        )

        let dto = CardExportDTO(from: card)
        #expect(dto.lastModifiedDate == nil)
    }

    @Test func recentlyEditedSortFallsBackToCreatedDate() {
        let older = Date(timeIntervalSince1970: 1000)
        let newer = Date(timeIntervalSince1970: 2000)

        let cardWithModified = LoyaltyCard(
            name: "Modified",
            barcodeType: .qr,
            barcodeData: "1",
            createdDate: older,
            lastModifiedDate: newer
        )

        let cardWithoutModified = LoyaltyCard(
            name: "Unmodified",
            barcodeType: .qr,
            barcodeData: "2",
            createdDate: newer
        )

        // Both should use their effective date for sorting
        let effectiveModified = cardWithModified.lastModifiedDate ?? cardWithModified.createdDate
        let effectiveUnmodified = cardWithoutModified.lastModifiedDate ?? cardWithoutModified.createdDate

        #expect(effectiveModified == newer)
        #expect(effectiveUnmodified == newer)
    }

    @Test func recentlyUsedSortBehavior() {
        let earlier = Date(timeIntervalSince1970: 1000)
        let later = Date(timeIntervalSince1970: 2000)

        let usedRecently = LoyaltyCard(
            name: "Used Recently",
            barcodeType: .qr,
            barcodeData: "1",
            lastUsedDate: later
        )

        let usedEarlier = LoyaltyCard(
            name: "Used Earlier",
            barcodeType: .qr,
            barcodeData: "2",
            lastUsedDate: earlier
        )

        let neverUsed = LoyaltyCard(
            name: "Never Used",
            barcodeType: .qr,
            barcodeData: "3"
        )

        var cards = [neverUsed, usedEarlier, usedRecently]
        cards.sort { (a: LoyaltyCard, b: LoyaltyCard) in
            (a.lastUsedDate ?? Date.distantPast) > (b.lastUsedDate ?? Date.distantPast)
        }

        #expect(cards[0].name == "Used Recently")
        #expect(cards[1].name == "Used Earlier")
        #expect(cards[2].name == "Never Used")
    }
}

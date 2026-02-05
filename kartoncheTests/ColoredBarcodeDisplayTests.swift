//
//  ColoredBarcodeDisplayTests.swift
//  kartoncheTests
//
//  Created on 2026-02-05.
//

import Testing
import SwiftUI
@testable import kartonche

@MainActor
struct ColoredBarcodeDisplayTests {
    
    @Test func cardWithPrimaryColorUsesIt() async throws {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Test Store",
            cardNumber: "123",
            barcodeType: .qr,
            barcodeData: "123",
            color: "#FF0000"
        )
        
        #expect(card.color == "#FF0000")
    }
    
    @Test func cardWithSecondaryColorStoresIt() async throws {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Test Store",
            cardNumber: "123",
            barcodeType: .qr,
            barcodeData: "123",
            color: "#FF0000",
            secondaryColor: "#FFFFFF"
        )
        
        #expect(card.color == "#FF0000")
        #expect(card.secondaryColor == "#FFFFFF")
    }
    
    @Test func cardWithoutColorsHasNilValues() async throws {
        let card = LoyaltyCard(
            name: "Test Card",
            storeName: "Test Store",
            cardNumber: "123",
            barcodeType: .qr,
            barcodeData: "123"
        )
        
        #expect(card.color == nil)
        #expect(card.secondaryColor == nil)
    }
    
    @Test func colorHexConversionWorks() async throws {
        let red = Color(hex: "#FF0000")
        #expect(red != nil)
        
        let invalid = Color(hex: "invalid")
        #expect(invalid == nil)
        
        let emptyString = Color(hex: "")
        #expect(emptyString == nil)
    }
}

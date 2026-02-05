//
//  BarcodeGeneratorTests.swift
//  kartoncheTests
//
//  Created on 5.2.2026.
//

import Testing
import UIKit
@testable import kartonche

struct BarcodeGeneratorTests {
    
    @Test func generateQRCode() {
        let result = BarcodeGenerator.generate(
            data: "https://example.com",
            type: .qr,
            scale: 5.0
        )
        
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("QR code generation failed: \(error)")
        }
    }
    
    @Test func generateCode128() {
        let result = BarcodeGenerator.generate(
            data: "ABC123",
            type: .code128,
            scale: 3.0
        )
        
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("Code128 generation failed: \(error)")
        }
    }
    
    @Test func generateEAN13() {
        let result = BarcodeGenerator.generate(
            data: "1234567890123",
            type: .ean13,
            scale: 3.0
        )
        
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("EAN-13 generation failed: \(error)")
        }
    }
    
    @Test func generatePDF417() {
        let result = BarcodeGenerator.generate(
            data: "PDF417DATA",
            type: .pdf417,
            scale: 3.0
        )
        
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("PDF417 generation failed: \(error)")
        }
    }
    
    @Test func generateAztec() {
        let result = BarcodeGenerator.generate(
            data: "AZTECCODE",
            type: .aztec,
            scale: 5.0
        )
        
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("Aztec code generation failed: \(error)")
        }
    }
    
    @Test func emptyDataReturnsError() {
        let result = BarcodeGenerator.generate(
            data: "",
            type: .qr,
            scale: 5.0
        )
        
        switch result {
        case .success:
            Issue.record("Empty data should fail")
        case .failure(let error):
            #expect(error == .invalidData)
        }
    }
    
    @Test func defaultScaleWorks() {
        let result = BarcodeGenerator.generate(
            data: "TEST",
            type: .qr
        )
        
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("Default scale generation failed: \(error)")
        }
    }
}

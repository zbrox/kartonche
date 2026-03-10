//
//  BarcodeGeneratorTests.swift
//  kartoncheTests
//
//  Created on 5.2.2026.
//

import Testing
import UIKit
@testable import kartonche

@MainActor
struct BarcodeGeneratorTests {

    @Test func generateQRCode() {
        let result = BarcodeGenerator.generate(
            from: "https://example.com",
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
            from: "ABC123",
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
            from: "1234567890123",
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
            from: "PDF417DATA",
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
            from: "AZTECCODE",
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
            from: "",
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
            from: "TEST",
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

    // MARK: - EAN-8

    @Test func generateEAN8() {
        let result = BarcodeGenerator.generate(from: "12345670", type: .ean8, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("EAN-8 generation failed: \(error)")
        }
    }

    @Test func ean8WrongDigitCountFails() {
        let result = BarcodeGenerator.generate(from: "12345", type: .ean8, scale: 3.0)
        switch result {
        case .success:
            Issue.record("EAN-8 with wrong digit count should fail")
        case .failure(let error):
            #expect(error == .digitCountMismatch(expected: 8, provided: 5))
        }
    }

    @Test func ean8EmptyFails() {
        let result = BarcodeGenerator.generate(from: "", type: .ean8, scale: 3.0)
        #expect(result == .failure(.invalidData))
    }

    // MARK: - Code 39

    @Test func generateCode39Numeric() {
        let result = BarcodeGenerator.generate(from: "12345", type: .code39, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("Code 39 generation failed: \(error)")
        }
    }

    @Test func generateCode39Alpha() {
        let result = BarcodeGenerator.generate(from: "HELLO", type: .code39, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("Code 39 alpha generation failed: \(error)")
        }
    }

    @Test func generateCode39MixedCase() {
        // Code 39 should auto-uppercase
        let result = BarcodeGenerator.generate(from: "Hello", type: .code39, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
        case .failure(let error):
            Issue.record("Code 39 mixed case generation failed: \(error)")
        }
    }

    @Test func code39InvalidCharacterFails() {
        let result = BarcodeGenerator.generate(from: "hello@world", type: .code39, scale: 3.0)
        #expect(result == .failure(.invalidData))
    }

    @Test func code39SpecialCharacters() {
        let result = BarcodeGenerator.generate(from: "A-B.C $", type: .code39, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
        case .failure(let error):
            Issue.record("Code 39 special chars failed: \(error)")
        }
    }

    // MARK: - Interleaved 2 of 5

    @Test func generateI2of5() {
        let result = BarcodeGenerator.generate(from: "1234567890", type: .interleaved2of5, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("I2of5 generation failed: \(error)")
        }
    }

    @Test func i2of5OddDigitCountFails() {
        let result = BarcodeGenerator.generate(from: "12345", type: .interleaved2of5, scale: 3.0)
        #expect(result == .failure(.invalidData))
    }

    @Test func i2of5NonDigitFails() {
        let result = BarcodeGenerator.generate(from: "12AB34", type: .interleaved2of5, scale: 3.0)
        #expect(result == .failure(.invalidData))
    }

    @Test func i2of5TwoDigits() {
        let result = BarcodeGenerator.generate(from: "42", type: .interleaved2of5, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
        case .failure(let error):
            Issue.record("I2of5 two-digit generation failed: \(error)")
        }
    }

    // MARK: - UPC-E

    @Test func generateUPCE6Digits() {
        let result = BarcodeGenerator.generate(from: "123456", type: .upcE, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("UPC-E 6-digit generation failed: \(error)")
        }
    }

    @Test func generateUPCE8Digits() {
        // 0 + 123456 + check digit 5
        let result = BarcodeGenerator.generate(from: "01234565", type: .upcE, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
        case .failure(let error):
            Issue.record("UPC-E 8-digit generation failed: \(error)")
        }
    }

    @Test func upceWrongCheckDigitFails() {
        let result = BarcodeGenerator.generate(from: "01234569", type: .upcE, scale: 3.0)
        #expect(result == .failure(.invalidData))
    }

    @Test func upce3DigitsFails() {
        let result = BarcodeGenerator.generate(from: "123", type: .upcE, scale: 3.0)
        switch result {
        case .success:
            Issue.record("UPC-E with 3 digits should fail")
        case .failure(let error):
            #expect(error == .digitCountMismatch(expected: 6, provided: 3))
        }
    }

    // MARK: - DataMatrix

    @Test func generateDataMatrix() {
        let result = BarcodeGenerator.generate(from: "Hello DataMatrix", type: .dataMatrix, scale: 5.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
            #expect(image.size.height > 0)
        case .failure(let error):
            Issue.record("DataMatrix generation failed: \(error)")
        }
    }

    @Test func dataMatrixSingleCharacter() {
        let result = BarcodeGenerator.generate(from: "A", type: .dataMatrix, scale: 3.0)
        switch result {
        case .success(let image):
            #expect(image.size.width > 0)
        case .failure(let error):
            Issue.record("DataMatrix single char failed: \(error)")
        }
    }

    // MARK: - EAN-13 digit count error

    @Test func ean13WrongDigitCountReturnsDigitCountMismatch() {
        let result = BarcodeGenerator.generate(from: "12345", type: .ean13, scale: 3.0)
        #expect(result == .failure(.digitCountMismatch(expected: 13, provided: 5)))
    }
}

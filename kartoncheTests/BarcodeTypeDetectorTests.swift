//
//  BarcodeTypeDetectorTests.swift
//  kartoncheTests
//
//  Created on 2026-03-10.
//

import Testing
import Vision
@testable import kartonche

@MainActor
struct BarcodeTypeDetectorTests {

    // MARK: - Existing symbologies

    @Test func qrSymbology() {
        #expect(BarcodeType(from: .qr) == .qr)
    }

    @Test func code128Symbology() {
        #expect(BarcodeType(from: .code128) == .code128)
    }

    @Test func ean13Symbology() {
        #expect(BarcodeType(from: .ean13) == .ean13)
    }

    @Test func pdf417Symbology() {
        #expect(BarcodeType(from: .pdf417) == .pdf417)
    }

    @Test func aztecSymbology() {
        #expect(BarcodeType(from: .aztec) == .aztec)
    }

    // MARK: - New symbologies

    @Test func code39Symbology() {
        #expect(BarcodeType(from: .code39) == .code39)
    }

    @Test func code39ChecksumSymbology() {
        #expect(BarcodeType(from: .code39Checksum) == .code39)
    }

    @Test func code39FullASCIISymbology() {
        #expect(BarcodeType(from: .code39FullASCII) == .code39)
    }

    @Test func code39FullASCIIChecksumSymbology() {
        #expect(BarcodeType(from: .code39FullASCIIChecksum) == .code39)
    }

    @Test func upceSymbology() {
        #expect(BarcodeType(from: .upce) == .upcE)
    }

    @Test func i2of5Symbology() {
        #expect(BarcodeType(from: .i2of5) == .interleaved2of5)
    }

    @Test func i2of5ChecksumSymbology() {
        #expect(BarcodeType(from: .i2of5Checksum) == .interleaved2of5)
    }

    @Test func dataMatrixSymbology() {
        #expect(BarcodeType(from: .dataMatrix) == .dataMatrix)
    }

    @Test func ean8Symbology() {
        #expect(BarcodeType(from: .ean8) == .ean8)
    }

    // MARK: - Unsupported symbologies

    @Test func unsupportedSymbologyReturnsNil() {
        #expect(BarcodeType(from: .codabar) == nil)
    }
}

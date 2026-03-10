//
//  BarcodeTypeTests.swift
//  kartoncheTests
//
//  Created on 2026-02-05.
//

import Testing
import Foundation
@testable import kartonche

@MainActor
struct BarcodeTypeTests {

    @Test func allCasesPresent() {
        let allCases = BarcodeType.allCases
        #expect(allCases.count == 10, "Should have exactly 10 barcode types")
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

    @Test func displayNames() {
        #expect(BarcodeType.qr.displayName == "QR Code")
        #expect(BarcodeType.code128.displayName == "Code 128")
        #expect(BarcodeType.ean13.displayName == "EAN-13")
        #expect(BarcodeType.pdf417.displayName == "PDF417")
        #expect(BarcodeType.aztec.displayName == "Aztec")
        #expect(BarcodeType.code39.displayName == "Code 39")
        #expect(BarcodeType.upcE.displayName == "UPC-E")
        #expect(BarcodeType.interleaved2of5.displayName == "Interleaved 2 of 5")
        #expect(BarcodeType.dataMatrix.displayName == "DataMatrix")
        #expect(BarcodeType.ean8.displayName == "EAN-8")
    }

    @Test func rawValues() {
        #expect(BarcodeType.qr.rawValue == "qr")
        #expect(BarcodeType.code128.rawValue == "code128")
        #expect(BarcodeType.ean13.rawValue == "ean13")
        #expect(BarcodeType.pdf417.rawValue == "pdf417")
        #expect(BarcodeType.aztec.rawValue == "aztec")
        #expect(BarcodeType.code39.rawValue == "code39")
        #expect(BarcodeType.upcE.rawValue == "upcE")
        #expect(BarcodeType.interleaved2of5.rawValue == "interleaved2of5")
        #expect(BarcodeType.dataMatrix.rawValue == "dataMatrix")
        #expect(BarcodeType.ean8.rawValue == "ean8")
    }

    @Test func codableRoundTrip() throws {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()

        for barcodeType in BarcodeType.allCases {
            let encoded = try encoder.encode(barcodeType)
            let decoded = try decoder.decode(BarcodeType.self, from: encoded)
            #expect(decoded == barcodeType, "Codable round-trip failed for \(barcodeType)")
        }
    }

    @Test func initFromRawValue() {
        #expect(BarcodeType(rawValue: "qr") == .qr)
        #expect(BarcodeType(rawValue: "code128") == .code128)
        #expect(BarcodeType(rawValue: "ean13") == .ean13)
        #expect(BarcodeType(rawValue: "pdf417") == .pdf417)
        #expect(BarcodeType(rawValue: "aztec") == .aztec)
        #expect(BarcodeType(rawValue: "code39") == .code39)
        #expect(BarcodeType(rawValue: "upcE") == .upcE)
        #expect(BarcodeType(rawValue: "interleaved2of5") == .interleaved2of5)
        #expect(BarcodeType(rawValue: "dataMatrix") == .dataMatrix)
        #expect(BarcodeType(rawValue: "ean8") == .ean8)
        #expect(BarcodeType(rawValue: "invalid") == nil, "Invalid raw value should return nil")
    }
}

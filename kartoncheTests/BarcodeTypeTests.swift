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
        #expect(allCases.count == 5, "Should have exactly 5 barcode types")
        #expect(allCases.contains(.qr))
        #expect(allCases.contains(.code128))
        #expect(allCases.contains(.ean13))
        #expect(allCases.contains(.pdf417))
        #expect(allCases.contains(.aztec))
    }
    
    @Test func displayNames() {
        #expect(BarcodeType.qr.displayName == "QR Code")
        #expect(BarcodeType.code128.displayName == "Code 128")
        #expect(BarcodeType.ean13.displayName == "EAN-13")
        #expect(BarcodeType.pdf417.displayName == "PDF417")
        #expect(BarcodeType.aztec.displayName == "Aztec")
    }
    
    @Test func rawValues() {
        #expect(BarcodeType.qr.rawValue == "qr")
        #expect(BarcodeType.code128.rawValue == "code128")
        #expect(BarcodeType.ean13.rawValue == "ean13")
        #expect(BarcodeType.pdf417.rawValue == "pdf417")
        #expect(BarcodeType.aztec.rawValue == "aztec")
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
        #expect(BarcodeType(rawValue: "invalid") == nil, "Invalid raw value should return nil")
    }
}

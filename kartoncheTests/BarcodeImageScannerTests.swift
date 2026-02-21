//
//  BarcodeImageScannerTests.swift
//  kartoncheTests
//
//  Created on 21.2.2026.
//

import Testing
import Vision
@testable import kartonche

@MainActor
struct BarcodeImageScannerTests {

    @Test func preferredMatchChoosesSupportedTypeFirst() {
        let unsupported = BarcodeImageMatch(
            data: "UNSUPPORTED",
            symbology: .upce,
            type: nil
        )
        let supported = BarcodeImageMatch(
            data: "SUPPORTED",
            symbology: .qr,
            type: .qr
        )

        let preferred = BarcodeImageScanner.preferredMatch(from: [unsupported, supported])

        #expect(preferred?.data == "SUPPORTED")
        #expect(preferred?.type == .qr)
    }

    @Test func preferredMatchFallsBackToFirstWhenNoSupportedType() {
        let first = BarcodeImageMatch(
            data: "FIRST",
            symbology: .upce,
            type: nil
        )
        let second = BarcodeImageMatch(
            data: "SECOND",
            symbology: .upce,
            type: nil
        )

        let preferred = BarcodeImageScanner.preferredMatch(from: [first, second])

        #expect(preferred?.data == "FIRST")
        #expect(preferred?.type == nil)
    }
}

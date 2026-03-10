//
//  BarcodeTypeWalletTests.swift
//  kartoncheTests
//
//  Created on 2026-02-10.
//

import Testing
@testable import kartonche

@MainActor
struct BarcodeTypeWalletTests {

    @Test func qrWalletFormatString() {
        #expect(BarcodeType.qr.walletFormatString == "PKBarcodeFormatQR")
    }

    @Test func code128WalletFormatString() {
        #expect(BarcodeType.code128.walletFormatString == "PKBarcodeFormatCode128")
    }

    @Test func pdf417WalletFormatString() {
        #expect(BarcodeType.pdf417.walletFormatString == "PKBarcodeFormatPDF417")
    }

    @Test func aztecWalletFormatString() {
        #expect(BarcodeType.aztec.walletFormatString == "PKBarcodeFormatAztec")
    }

    @Test func ean13WalletFormatStringIsNil() {
        #expect(BarcodeType.ean13.walletFormatString == nil)
    }

    @Test func code39WalletFormatStringIsNil() {
        #expect(BarcodeType.code39.walletFormatString == nil)
    }

    @Test func upcEWalletFormatStringIsNil() {
        #expect(BarcodeType.upcE.walletFormatString == nil)
    }

    @Test func interleaved2of5WalletFormatStringIsNil() {
        #expect(BarcodeType.interleaved2of5.walletFormatString == nil)
    }

    @Test func dataMatrixWalletFormatStringIsNil() {
        #expect(BarcodeType.dataMatrix.walletFormatString == nil)
    }

    @Test func ean8WalletFormatStringIsNil() {
        #expect(BarcodeType.ean8.walletFormatString == nil)
    }
}

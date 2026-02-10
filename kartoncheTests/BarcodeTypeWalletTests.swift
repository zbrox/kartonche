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

    @Test func qrSupportsAppleWallet() {
        #expect(BarcodeType.qr.supportsAppleWallet == true)
    }

    @Test func code128SupportsAppleWallet() {
        #expect(BarcodeType.code128.supportsAppleWallet == true)
    }

    @Test func pdf417SupportsAppleWallet() {
        #expect(BarcodeType.pdf417.supportsAppleWallet == true)
    }

    @Test func aztecSupportsAppleWallet() {
        #expect(BarcodeType.aztec.supportsAppleWallet == true)
    }

    @Test func ean13DoesNotSupportAppleWallet() {
        #expect(BarcodeType.ean13.supportsAppleWallet == false)
    }

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
}

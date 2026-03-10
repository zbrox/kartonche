//
//  BarcodeType.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import Foundation

enum BarcodeType: String, Codable, CaseIterable {
    case qr
    case code128
    case ean13
    case pdf417
    case aztec
    case code39
    case upcE
    case interleaved2of5
    case dataMatrix
    case ean8

    var displayName: String {
        switch self {
        case .qr:
            return "QR Code"
        case .code128:
            return "Code 128"
        case .ean13:
            return "EAN-13"
        case .pdf417:
            return "PDF417"
        case .aztec:
            return "Aztec"
        case .code39:
            return "Code 39"
        case .upcE:
            return "UPC-E"
        case .interleaved2of5:
            return "Interleaved 2 of 5"
        case .dataMatrix:
            return "DataMatrix"
        case .ean8:
            return "EAN-8"
        }
    }

    var walletFormatString: String? {
        switch self {
        case .qr: return "PKBarcodeFormatQR"
        case .code128: return "PKBarcodeFormatCode128"
        case .pdf417: return "PKBarcodeFormatPDF417"
        case .aztec: return "PKBarcodeFormatAztec"
        case .ean13, .code39, .upcE, .interleaved2of5, .dataMatrix, .ean8:
            return nil
        }
    }
}

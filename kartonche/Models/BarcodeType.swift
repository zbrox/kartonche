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
        }
    }

    var supportsAppleWallet: Bool {
        self != .ean13
    }

    var walletFormatString: String? {
        switch self {
        case .qr: return "PKBarcodeFormatQR"
        case .code128: return "PKBarcodeFormatCode128"
        case .pdf417: return "PKBarcodeFormatPDF417"
        case .aztec: return "PKBarcodeFormatAztec"
        case .ean13: return nil
        }
    }
}

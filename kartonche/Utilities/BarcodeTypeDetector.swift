//
//  BarcodeTypeDetector.swift
//  kartonche
//
//  Created on 2026-02-06.
//

import Vision

extension BarcodeType {
    init?(from symbology: VNBarcodeSymbology) {
        switch symbology {
        case .qr:
            self = .qr
        case .code128:
            self = .code128
        case .ean13:
            self = .ean13
        case .pdf417:
            self = .pdf417
        case .aztec:
            self = .aztec
        default:
            return nil
        }
    }
}

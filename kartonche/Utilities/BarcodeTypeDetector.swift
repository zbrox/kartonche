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
        case .code39, .code39Checksum, .code39FullASCII, .code39FullASCIIChecksum:
            self = .code39
        case .upce:
            self = .upcE
        case .i2of5, .i2of5Checksum:
            self = .interleaved2of5
        case .dataMatrix:
            self = .dataMatrix
        case .ean8:
            self = .ean8
        default:
            return nil
        }
    }
}

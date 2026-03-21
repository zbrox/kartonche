//
//  BarcodeTypeAppEnum.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents

extension BarcodeType: AppEnum {
    nonisolated static var typeDisplayRepresentation: TypeDisplayRepresentation {
        TypeDisplayRepresentation(name: "Barcode Type")
    }

    nonisolated static var caseDisplayRepresentations: [BarcodeType: DisplayRepresentation] {
        [
            .qr: "QR Code",
            .code128: "Code 128",
            .ean13: "EAN-13",
            .pdf417: "PDF417",
            .aztec: "Aztec",
            .code39: "Code 39",
            .upcE: "UPC-E",
            .interleaved2of5: "Interleaved 2 of 5",
            .dataMatrix: "DataMatrix",
            .ean8: "EAN-8",
        ]
    }
}

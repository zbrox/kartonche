//
//  BarcodeImageScanner.swift
//  kartonche
//
//  Created on 21.2.2026.
//

import UIKit
import Vision

struct BarcodeImageMatch: Equatable {
    let data: String
    let symbology: VNBarcodeSymbology
    let type: BarcodeType?
}

enum BarcodeImageScanner {

    static func scan(from imageData: Data) async throws -> [BarcodeImageMatch] {
        guard let image = UIImage(data: imageData) else {
            throw PhotoBarcodeScanner.ScanError.invalidImage
        }
        return try await scan(from: image)
    }

    static func scan(from image: UIImage) async throws -> [BarcodeImageMatch] {
        let barcodes = try await PhotoBarcodeScanner.scanBarcodes(from: image)
        return barcodes.map { barcode in
            BarcodeImageMatch(
                data: barcode.data,
                symbology: barcode.symbology,
                type: BarcodeType(from: barcode.symbology)
            )
        }
    }

    static func preferredMatch(from matches: [BarcodeImageMatch]) -> BarcodeImageMatch? {
        if let supported = matches.first(where: { $0.type != nil }) {
            return supported
        }
        return matches.first
    }
}

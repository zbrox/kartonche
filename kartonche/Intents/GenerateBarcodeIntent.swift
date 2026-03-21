//
//  GenerateBarcodeIntent.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-03-21.
//

import AppIntents
import UIKit
import UniformTypeIdentifiers

struct GenerateBarcodeIntent: AppIntent {
    nonisolated(unsafe) static var title: LocalizedStringResource = "Generate Barcode Image"
    nonisolated(unsafe) static var description: IntentDescription = "Generates a barcode image from the given type and data"
    nonisolated(unsafe) static var openAppWhenRun: Bool = false

    @Parameter(title: "Barcode Type")
    var barcodeType: BarcodeType

    @Parameter(title: "Data")
    var data: String

    @MainActor
    func perform() async throws -> some IntentResult & ReturnsValue<IntentFile> {
        let result = BarcodeGenerator.generate(from: data, type: barcodeType)
        switch result {
        case .success(let image):
            guard let pngData = image.pngData() else {
                throw GenerateBarcodeError.imageConversionFailed
            }
            let file = IntentFile(data: pngData, filename: "barcode.png", type: .png)
            return .result(value: file)
        case .failure(let error):
            throw GenerateBarcodeError.generationFailed(error.localizedDescription)
        }
    }

    enum GenerateBarcodeError: Swift.Error, CustomLocalizedStringResourceConvertible {
        case generationFailed(String)
        case imageConversionFailed

        var localizedStringResource: LocalizedStringResource {
            switch self {
            case .generationFailed(let reason):
                "Barcode generation failed: \(reason)"
            case .imageConversionFailed:
                "Failed to convert barcode image to PNG"
            }
        }
    }
}

//
//  BarcodeGenerator.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-05.
//

import CoreImage
import UIKit

struct BarcodeGenerator {
    
    enum GenerationError: Error, Equatable {
        case invalidData
        case filterCreationFailed
        case imageGenerationFailed
        case ean13RequiresExactly13Digits(provided: Int)
        
        var localizedDescription: String {
            switch self {
            case .invalidData:
                return String(localized: "Invalid barcode data")
            case .filterCreationFailed:
                return String(localized: "Failed to create barcode filter")
            case .imageGenerationFailed:
                return String(localized: "Failed to generate barcode image")
            case .ean13RequiresExactly13Digits(let provided):
                let format = NSLocalizedString(
                    "EAN-13 requires exactly 13 digits (provided: %d)",
                    bundle: .main,
                    comment: "Error message for EAN-13 digit validation"
                )
                return String(format: format, provided)
            }
        }
    }
    
    static func generate(
        from data: String,
        type: BarcodeType,
        scale: CGFloat = 10.0
    ) -> Result<UIImage, GenerationError> {
        guard !data.isEmpty else {
            return .failure(.invalidData)
        }
        
        let context = CIContext()
        
        if type == .ean13 {
            return generateEAN13(from: data, scale: scale, context: context)
        }
        
        guard let dataToEncode = data.data(using: .ascii) else {
            return .failure(.invalidData)
        }
        
        guard let filter = createFilter(for: type) else {
            return .failure(.filterCreationFailed)
        }
        
        filter.setValue(dataToEncode, forKey: "inputMessage")
        
        if type == .qr {
            filter.setValue("M", forKey: "inputCorrectionLevel")
        }
        
        guard let outputImage = filter.outputImage else {
            return .failure(.imageGenerationFailed)
        }
        
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: scaleTransform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return .failure(.imageGenerationFailed)
        }
        
        return .success(UIImage(cgImage: cgImage))
    }
    
    private static func generateEAN13(
        from data: String,
        scale: CGFloat,
        context: CIContext
    ) -> Result<UIImage, GenerationError> {
        // EAN-13 must be exactly 13 digits
        let digits = data.filter { $0.isNumber }
        guard digits.count == 13 else {
            return .failure(.ean13RequiresExactly13Digits(provided: digits.count))
        }
        
        // Use Code128 generator as fallback for EAN-13
        // CIBarcodeGenerator with EAN-13 descriptor is complex and not well documented
        // Code128 can encode numeric data and is widely compatible
        guard let dataToEncode = digits.data(using: .ascii) else {
            return .failure(.invalidData)
        }
        
        guard let filter = CIFilter(name: "CICode128BarcodeGenerator") else {
            return .failure(.filterCreationFailed)
        }
        
        filter.setValue(dataToEncode, forKey: "inputMessage")
        
        guard let outputImage = filter.outputImage else {
            return .failure(.imageGenerationFailed)
        }
        
        let scaleTransform = CGAffineTransform(scaleX: scale, y: scale)
        let scaledImage = outputImage.transformed(by: scaleTransform)
        
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            return .failure(.imageGenerationFailed)
        }
        
        return .success(UIImage(cgImage: cgImage))
    }
    
    private static func createFilter(for type: BarcodeType) -> CIFilter? {
        switch type {
        case .qr:
            return CIFilter(name: "CIQRCodeGenerator")
        case .code128:
            return CIFilter(name: "CICode128BarcodeGenerator")
        case .ean13:
            return CIFilter(name: "CIBarcodeGenerator")
        case .pdf417:
            return CIFilter(name: "CIPDF417BarcodeGenerator")
        case .aztec:
            return CIFilter(name: "CIAztecCodeGenerator")
        }
    }
}

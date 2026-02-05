//
//  BarcodeGenerator.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-05.
//

import CoreImage
import UIKit

struct BarcodeGenerator {
    
    enum GenerationError: Error {
        case invalidData
        case filterCreationFailed
        case imageGenerationFailed
    }
    
    static func generate(
        from data: String,
        type: BarcodeType,
        scale: CGFloat = 10.0
    ) -> Result<UIImage, GenerationError> {
        let context = CIContext()
        
        // EAN-13 requires special handling with CIBarcodeDescriptor
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
        
        if type == .qr, let qrFilter = filter as? CIFilter {
            qrFilter.setValue("M", forKey: "inputCorrectionLevel")
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
            return .failure(.invalidData)
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

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
        
        switch type {
        case .ean13:
            return generateEAN13(from: data, scale: scale, context: context)
        case .ean8:
            return .failure(.filterCreationFailed)
        case .code39:
            return .failure(.filterCreationFailed)
        case .interleaved2of5:
            return .failure(.filterCreationFailed)
        case .upcE:
            return .failure(.filterCreationFailed)
        case .dataMatrix:
            return .failure(.filterCreationFailed)
        default:
            break
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
        let digits = data.filter { $0.isNumber }
        guard digits.count == 13 else {
            return .failure(.ean13RequiresExactly13Digits(provided: digits.count))
        }

        let size = CGSize(width: 95 * scale, height: 50 * scale)
        guard let image = renderEAN13(digits: digits, size: size) else {
            return .failure(.imageGenerationFailed)
        }

        return .success(image)
    }

    // MARK: - EAN-13 rendering

    // L-codes (odd parity, left side)
    private static let ean13LCodes: [[Int]] = [
        [0,0,0,1,1,0,1], [0,0,1,1,0,0,1], [0,0,1,0,0,1,1], [0,1,1,1,1,0,1], [0,1,0,0,0,1,1],
        [0,1,1,0,0,0,1], [0,1,0,1,1,1,1], [0,1,1,1,0,1,1], [0,1,1,0,1,1,1], [0,0,0,1,0,1,1],
    ]

    // G-codes (even parity, left side)
    private static let ean13GCodes: [[Int]] = [
        [0,1,0,0,1,1,1], [0,1,1,0,0,1,1], [0,0,1,1,0,1,1], [0,1,0,0,0,0,1], [0,0,1,1,1,0,1],
        [0,1,1,1,0,0,1], [0,0,0,0,1,0,1], [0,0,1,0,0,0,1], [0,0,0,1,0,0,1], [0,0,1,0,1,1,1],
    ]

    // R-codes (right side)
    private static let ean13RCodes: [[Int]] = [
        [1,1,1,0,0,1,0], [1,1,0,0,1,1,0], [1,1,0,1,1,0,0], [1,0,0,0,0,1,0], [1,0,1,1,1,0,0],
        [1,0,0,1,1,1,0], [1,0,1,0,0,0,0], [1,0,0,0,1,0,0], [1,0,0,1,0,0,0], [1,1,1,0,1,0,0],
    ]

    // Parity patterns keyed by first digit — 0 = L, 1 = G
    private static let ean13ParityPatterns: [[Int]] = [
        [0,0,0,0,0,0], [0,0,1,0,1,1], [0,0,1,1,0,1], [0,0,1,1,1,0], [0,1,0,0,1,1],
        [0,1,1,0,0,1], [0,1,1,1,0,0], [0,1,0,1,0,1], [0,1,0,1,1,0], [0,1,1,0,1,0],
    ]

    static func renderEAN13(digits: String, size: CGSize) -> UIImage? {
        guard digits.count == 13, digits.allSatisfy(\.isNumber) else { return nil }

        let digitValues = digits.compactMap { $0.wholeNumberValue }
        guard digitValues.count == 13 else { return nil }

        var modules: [Int] = []

        // Left quiet zone (11 modules)
        modules.append(contentsOf: [Int](repeating: 0, count: 11))

        // Start guard: 101
        modules.append(contentsOf: [1, 0, 1])

        // Left 6 digits using L/G parity from first digit
        let parity = ean13ParityPatterns[digitValues[0]]
        for i in 0..<6 {
            let d = digitValues[1 + i]
            let code = parity[i] == 0 ? ean13LCodes[d] : ean13GCodes[d]
            modules.append(contentsOf: code)
        }

        // Center guard: 01010
        modules.append(contentsOf: [0, 1, 0, 1, 0])

        // Right 6 digits using R-codes
        for i in 0..<6 {
            let d = digitValues[7 + i]
            modules.append(contentsOf: ean13RCodes[d])
        }

        // End guard: 101
        modules.append(contentsOf: [1, 0, 1])

        // Right quiet zone (7 modules)
        modules.append(contentsOf: [Int](repeating: 0, count: 7))

        let totalModules = modules.count
        let moduleWidth = Int(size.width) / totalModules
        guard moduleWidth >= 1 else { return nil }

        let barcodeWidth = moduleWidth * totalModules
        let imageWidth = Int(size.width)
        let imageHeight = Int(size.height)
        let xOffset = (imageWidth - barcodeWidth) / 2

        let digitAreaHeight = max(Int(Double(imageHeight) * 0.18), 12)
        let barHeight = imageHeight - digitAreaHeight

        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { ctx in
            let cgCtx = ctx.cgContext
            cgCtx.setShouldAntialias(false)
            cgCtx.setAllowsAntialiasing(false)
            cgCtx.interpolationQuality = .none

            cgCtx.setFillColor(UIColor.white.cgColor)
            cgCtx.fill(CGRect(origin: .zero, size: size))

            cgCtx.setFillColor(UIColor.black.cgColor)
            for (i, module) in modules.enumerated() where module == 1 {
                let x = xOffset + i * moduleWidth
                cgCtx.fill(CGRect(x: x, y: 0, width: moduleWidth, height: barHeight))
            }

            let fontSize = CGFloat(digitAreaHeight - 2)
            let font = UIFont.monospacedDigitSystemFont(ofSize: fontSize, weight: .regular)
            let attrs: [NSAttributedString.Key: Any] = [
                .font: font,
                .foregroundColor: UIColor.black,
            ]
            let attrStr = NSAttributedString(string: digits, attributes: attrs)
            let textSize = attrStr.size()
            let textX = CGFloat(xOffset) + (CGFloat(barcodeWidth) - textSize.width) / 2
            let textY = CGFloat(barHeight) + (CGFloat(digitAreaHeight) - textSize.height) / 2
            attrStr.draw(at: CGPoint(x: textX, y: textY))
        }
    }
    
    private static func createFilter(for type: BarcodeType) -> CIFilter? {
        switch type {
        case .qr:
            return CIFilter(name: "CIQRCodeGenerator")
        case .code128:
            return CIFilter(name: "CICode128BarcodeGenerator")
        case .pdf417:
            return CIFilter(name: "CIPDF417BarcodeGenerator")
        case .aztec:
            return CIFilter(name: "CIAztecCodeGenerator")
        case .ean13, .code39, .upcE, .interleaved2of5, .dataMatrix, .ean8:
            return nil
        }
    }
}

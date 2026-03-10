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
        case digitCountMismatch(expected: Int, provided: Int)

        var localizedDescription: String {
            switch self {
            case .invalidData:
                return String(localized: "Invalid barcode data")
            case .filterCreationFailed:
                return String(localized: "Failed to create barcode filter")
            case .imageGenerationFailed:
                return String(localized: "Failed to generate barcode image")
            case .digitCountMismatch(let expected, let provided):
                let format = NSLocalizedString(
                    "Expected exactly %d digits (provided: %d)",
                    bundle: .main,
                    comment: "Error message for barcode digit validation"
                )
                return String(format: format, expected, provided)
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
            return generateEAN8(from: data, scale: scale)
        case .code39:
            return generateCode39(from: data, scale: scale)
        case .interleaved2of5:
            return generateInterleaved2of5(from: data, scale: scale)
        case .upcE:
            return generateUPCE(from: data, scale: scale)
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
            return .failure(.digitCountMismatch(expected: 13, provided: digits.count))
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
    
    // MARK: - EAN-8 rendering

    private static func generateEAN8(
        from data: String,
        scale: CGFloat
    ) -> Result<UIImage, GenerationError> {
        let digits = data.filter { $0.isNumber }
        guard digits.count == 8 else {
            return .failure(.digitCountMismatch(expected: 8, provided: digits.count))
        }

        let digitValues = digits.compactMap { $0.wholeNumberValue }
        guard digitValues.count == 8 else { return .failure(.invalidData) }

        var modules: [Int] = []

        // Left quiet zone (7 modules)
        modules.append(contentsOf: [Int](repeating: 0, count: 7))

        // Start guard: 101
        modules.append(contentsOf: [1, 0, 1])

        // Left 4 digits using L-codes
        for i in 0..<4 {
            modules.append(contentsOf: ean13LCodes[digitValues[i]])
        }

        // Center guard: 01010
        modules.append(contentsOf: [0, 1, 0, 1, 0])

        // Right 4 digits using R-codes
        for i in 4..<8 {
            modules.append(contentsOf: ean13RCodes[digitValues[i]])
        }

        // End guard: 101
        modules.append(contentsOf: [1, 0, 1])

        // Right quiet zone (7 modules)
        modules.append(contentsOf: [Int](repeating: 0, count: 7))

        let size = CGSize(width: 81 * scale, height: 50 * scale)
        guard let image = renderLinearBarcode(modules: modules, text: digits, size: size) else {
            return .failure(.imageGenerationFailed)
        }
        return .success(image)
    }

    // MARK: - Code 39 rendering

    // Code 39: each character maps to 9 elements (bars and spaces alternating, starting with bar)
    // 1 = wide, 0 = narrow
    private static let code39Patterns: [Character: [Int]] = [
        "0": [0,0,0,1,1,0,1,0,0], "1": [1,0,0,1,0,0,0,0,1], "2": [0,0,1,1,0,0,0,0,1],
        "3": [1,0,1,1,0,0,0,0,0], "4": [0,0,0,1,1,0,0,0,1], "5": [1,0,0,1,1,0,0,0,0],
        "6": [0,0,1,1,1,0,0,0,0], "7": [0,0,0,1,0,0,1,0,1], "8": [1,0,0,1,0,0,1,0,0],
        "9": [0,0,1,1,0,0,1,0,0], "A": [1,0,0,0,0,1,0,0,1], "B": [0,0,1,0,0,1,0,0,1],
        "C": [1,0,1,0,0,1,0,0,0], "D": [0,0,0,0,1,1,0,0,1], "E": [1,0,0,0,1,1,0,0,0],
        "F": [0,0,1,0,1,1,0,0,0], "G": [0,0,0,0,0,1,1,0,1], "H": [1,0,0,0,0,1,1,0,0],
        "I": [0,0,1,0,0,1,1,0,0], "J": [0,0,0,0,1,1,1,0,0], "K": [1,0,0,0,0,0,0,1,1],
        "L": [0,0,1,0,0,0,0,1,1], "M": [1,0,1,0,0,0,0,1,0], "N": [0,0,0,0,1,0,0,1,1],
        "O": [1,0,0,0,1,0,0,1,0], "P": [0,0,1,0,1,0,0,1,0], "Q": [0,0,0,0,0,0,1,1,1],
        "R": [1,0,0,0,0,0,1,1,0], "S": [0,0,1,0,0,0,1,1,0], "T": [0,0,0,0,1,0,1,1,0],
        "U": [1,1,0,0,0,0,0,0,1], "V": [0,1,1,0,0,0,0,0,1], "W": [1,1,1,0,0,0,0,0,0],
        "X": [0,1,0,0,1,0,0,0,1], "Y": [1,1,0,0,1,0,0,0,0], "Z": [0,1,1,0,1,0,0,0,0],
        "-": [0,1,0,0,0,0,1,0,1], ".": [1,1,0,0,0,0,1,0,0], " ": [0,1,1,0,0,0,1,0,0],
        "$": [0,1,0,1,0,1,0,0,0], "/": [0,1,0,1,0,0,0,1,0], "+": [0,1,0,0,0,1,0,1,0],
        "%": [0,0,0,1,0,1,0,1,0], "*": [0,1,0,0,1,0,1,0,0],
    ]

    private static func generateCode39(
        from data: String,
        scale: CGFloat
    ) -> Result<UIImage, GenerationError> {
        let uppercased = data.uppercased()
        let chars = Array(uppercased)

        // Validate all characters
        for char in chars {
            guard code39Patterns[char] != nil else {
                return .failure(.invalidData)
            }
        }

        let narrow = 1
        let wide = 3
        let interCharGap = 1

        // Build modules: start(*) + gap + data chars with gaps + stop(*)
        var modules: [Int] = []

        // Quiet zone
        modules.append(contentsOf: [Int](repeating: 0, count: 10))

        let allChars: [Character] = ["*"] + chars + ["*"]
        for (charIndex, char) in allChars.enumerated() {
            guard let pattern = code39Patterns[char] else { return .failure(.invalidData) }

            for (elementIndex, element) in pattern.enumerated() {
                let width = element == 1 ? wide : narrow
                let isBar = elementIndex % 2 == 0
                let value = isBar ? 1 : 0
                modules.append(contentsOf: [Int](repeating: value, count: width))
            }

            if charIndex < allChars.count - 1 {
                modules.append(contentsOf: [Int](repeating: 0, count: interCharGap))
            }
        }

        // Quiet zone
        modules.append(contentsOf: [Int](repeating: 0, count: 10))

        let size = CGSize(width: CGFloat(modules.count) * scale, height: 50 * scale)
        guard let image = renderLinearBarcode(modules: modules, text: uppercased, size: size) else {
            return .failure(.imageGenerationFailed)
        }
        return .success(image)
    }

    // MARK: - Interleaved 2 of 5 rendering

    // I2of5: digit patterns — positions of wide elements among 5 (NNWWN etc.)
    private static let i2of5Patterns: [[Int]] = [
        [0,0,1,1,0], // 0: NNWWN
        [1,0,0,0,1], // 1: WNNNN → WNNNW
        [0,1,0,0,1], // 2
        [1,1,0,0,0], // 3
        [0,0,1,0,1], // 4
        [1,0,1,0,0], // 5
        [0,1,1,0,0], // 6
        [0,0,0,1,1], // 7
        [1,0,0,1,0], // 8
        [0,1,0,1,0], // 9
    ]

    private static func generateInterleaved2of5(
        from data: String,
        scale: CGFloat
    ) -> Result<UIImage, GenerationError> {
        let digits = data.filter { $0.isNumber }
        guard digits.count == data.count else { return .failure(.invalidData) }
        guard digits.count >= 2, digits.count % 2 == 0 else {
            return .failure(.invalidData)
        }

        let narrow = 1
        let wide = 3

        var modules: [Int] = []

        // Quiet zone
        modules.append(contentsOf: [Int](repeating: 0, count: 10))

        // Start: narrow bar, narrow space, narrow bar, narrow space
        modules.append(contentsOf: [1, 0, 1, 0])

        let digitValues = digits.compactMap { $0.wholeNumberValue }

        // Encode digit pairs
        for pairIndex in stride(from: 0, to: digitValues.count, by: 2) {
            let barPattern = i2of5Patterns[digitValues[pairIndex]]
            let spacePattern = i2of5Patterns[digitValues[pairIndex + 1]]

            for i in 0..<5 {
                let barWidth = barPattern[i] == 1 ? wide : narrow
                let spaceWidth = spacePattern[i] == 1 ? wide : narrow
                modules.append(contentsOf: [Int](repeating: 1, count: barWidth))
                modules.append(contentsOf: [Int](repeating: 0, count: spaceWidth))
            }
        }

        // Stop: wide bar, narrow space, narrow bar
        modules.append(contentsOf: [Int](repeating: 1, count: wide))
        modules.append(0)
        modules.append(1)

        // Quiet zone
        modules.append(contentsOf: [Int](repeating: 0, count: 10))

        let size = CGSize(width: CGFloat(modules.count) * scale, height: 50 * scale)
        guard let image = renderLinearBarcode(modules: modules, text: digits, size: size) else {
            return .failure(.imageGenerationFailed)
        }
        return .success(image)
    }

    // MARK: - UPC-E rendering

    // UPC-E parity patterns keyed by check digit (for number system 0)
    private static let upceParityPatterns: [[Int]] = [
        [1,1,1,0,0,0], // 0: EEEOOO
        [1,1,0,1,0,0], // 1
        [1,1,0,0,1,0], // 2
        [1,1,0,0,0,1], // 3
        [1,0,1,1,0,0], // 4
        [1,0,0,1,1,0], // 5
        [1,0,0,0,1,1], // 6
        [1,0,1,0,1,0], // 7
        [1,0,1,0,0,1], // 8
        [1,0,0,1,0,1], // 9
    ]

    // Odd parity encodings (same as EAN-13 L-codes)
    private static let upceOddCodes: [[Int]] = ean13LCodes

    // Even parity encodings (same as EAN-13 G-codes)
    private static let upceEvenCodes: [[Int]] = ean13GCodes

    private static func generateUPCE(
        from data: String,
        scale: CGFloat
    ) -> Result<UIImage, GenerationError> {
        let digits = data.filter { $0.isNumber }

        // Accept 6-digit (payload only), 7-digit (with number system), or 8-digit (with check digit)
        let payload: String
        let checkDigit: Int

        switch digits.count {
        case 6:
            let expanded = expandUPCE(digits)
            checkDigit = calculateUPCACheckDigit(expanded)
            payload = digits
        case 7:
            // First digit is number system (must be 0), last 6 are payload
            guard digits.first == "0" else { return .failure(.invalidData) }
            let p = String(digits.dropFirst())
            let expanded = expandUPCE(p)
            checkDigit = calculateUPCACheckDigit(expanded)
            payload = p
        case 8:
            guard digits.first == "0" else { return .failure(.invalidData) }
            let p = String(digits.dropFirst().dropLast())
            let expanded = expandUPCE(p)
            let expectedCheck = calculateUPCACheckDigit(expanded)
            guard let provided = digits.last?.wholeNumberValue, provided == expectedCheck else {
                return .failure(.invalidData)
            }
            checkDigit = expectedCheck
            payload = p
        default:
            return .failure(.digitCountMismatch(expected: 6, provided: digits.count))
        }

        let digitValues = payload.compactMap { $0.wholeNumberValue }
        guard digitValues.count == 6 else { return .failure(.invalidData) }

        let parity = upceParityPatterns[checkDigit]

        var modules: [Int] = []

        // Quiet zone (9 modules)
        modules.append(contentsOf: [Int](repeating: 0, count: 9))

        // Start guard: 101
        modules.append(contentsOf: [1, 0, 1])

        // 6 data digits
        for i in 0..<6 {
            let d = digitValues[i]
            let code = parity[i] == 1 ? upceEvenCodes[d] : upceOddCodes[d]
            modules.append(contentsOf: code)
        }

        // End guard: 010101
        modules.append(contentsOf: [0, 1, 0, 1, 0, 1])

        // Quiet zone (9 modules)
        modules.append(contentsOf: [Int](repeating: 0, count: 9))

        let size = CGSize(width: CGFloat(modules.count) * scale, height: 50 * scale)
        guard let image = renderLinearBarcode(modules: modules, text: digits, size: size) else {
            return .failure(.imageGenerationFailed)
        }
        return .success(image)
    }

    // Expand 6-digit UPC-E to 11-digit UPC-A (without check digit)
    private static func expandUPCE(_ sixDigits: String) -> String {
        let d = Array(sixDigits)
        guard d.count == 6 else { return sixDigits }

        let lastDigit = d[5]
        var expanded: String

        switch lastDigit {
        case "0", "1", "2":
            expanded = "0\(d[0])\(d[1])\(lastDigit)0000\(d[2])\(d[3])\(d[4])"
        case "3":
            expanded = "0\(d[0])\(d[1])\(d[2])00000\(d[3])\(d[4])"
        case "4":
            expanded = "0\(d[0])\(d[1])\(d[2])\(d[3])00000\(d[4])"
        default: // 5-9
            expanded = "0\(d[0])\(d[1])\(d[2])\(d[3])\(d[4])0000\(lastDigit)"
        }

        return expanded
    }

    private static func calculateUPCACheckDigit(_ elevenDigits: String) -> Int {
        let values = elevenDigits.compactMap { $0.wholeNumberValue }
        guard values.count == 11 else { return 0 }

        var sum = 0
        for (i, v) in values.enumerated() {
            sum += (i % 2 == 0) ? v * 3 : v
        }
        return (10 - (sum % 10)) % 10
    }

    // MARK: - Linear barcode rendering helper

    private static func renderLinearBarcode(modules: [Int], text: String, size: CGSize) -> UIImage? {
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
            let attrStr = NSAttributedString(string: text, attributes: attrs)
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

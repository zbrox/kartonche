//
//  DominantColorExtractor.swift
//  kartonche
//

import SwiftUI
import UIKit
import CoreImage
import Vision

/// Extracts the dominant color from a UIImage using pixel-bucketed color quantization
enum DominantColorExtractor {

    struct Analysis {
        let primaryColor: Color?
        let suggestedColors: [Color]
        let confidence: Double
    }

    /// Extracts the dominant color from an image.
    ///
    /// Downscales the image, quantizes pixel colors into buckets, picks the most frequent bucket,
    /// then averages original RGB values within that bucket for a smoother result.
    ///
    /// - Parameter image: The source image
    /// - Returns: The dominant color, or `nil` if the image cannot be read
    static func extractDominantColor(from image: UIImage) -> Color? {
        let analysis = analyzeColors(from: image)
        guard analysis.confidence >= 0.12 else { return nil }
        return analysis.primaryColor
    }

    static func analyzeColors(from image: UIImage) -> Analysis {
        guard let sourceCGImage = readableCGImage(from: image) else {
            return Analysis(primaryColor: nil, suggestedColors: [], confidence: 0)
        }

        let cgImage = cropToLikelyCardRegion(from: sourceCGImage) ?? sourceCGImage

        let targetSize = 50
        let width = targetSize
        let height = targetSize

        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bytesPerPixel = 4
        let bytesPerRow = bytesPerPixel * width
        let bitmapInfo = CGImageAlphaInfo.premultipliedLast.rawValue | CGBitmapInfo.byteOrder32Big.rawValue

        var pixelData = [UInt8](repeating: 0, count: width * height * bytesPerPixel)
        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: colorSpace,
            bitmapInfo: bitmapInfo
        ) else { return Analysis(primaryColor: nil, suggestedColors: [], confidence: 0) }

        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Quantization step — round each channel to nearest multiple of 32
        let quantizationStep: UInt8 = 32

        struct BucketKey: Hashable {
            let r: UInt8
            let g: UInt8
            let b: UInt8
        }

        struct BucketAccumulator {
            var totalR: UInt64 = 0
            var totalG: UInt64 = 0
            var totalB: UInt64 = 0
            var count: UInt64 = 0
        }

        var buckets: [BucketKey: BucketAccumulator] = [:]

        for i in 0..<(width * height) {
            let offset = i * bytesPerPixel
            let r = pixelData[offset]
            let g = pixelData[offset + 1]
            let b = pixelData[offset + 2]

            let qr = (r / quantizationStep) * quantizationStep
            let qg = (g / quantizationStep) * quantizationStep
            let qb = (b / quantizationStep) * quantizationStep

            let key = BucketKey(r: qr, g: qg, b: qb)
            var acc = buckets[key] ?? BucketAccumulator()
            acc.totalR += UInt64(r)
            acc.totalG += UInt64(g)
            acc.totalB += UInt64(b)
            acc.count += 1
            buckets[key] = acc
        }

        guard !buckets.isEmpty else {
            return Analysis(primaryColor: nil, suggestedColors: [], confidence: 0)
        }

        let totalPixels = Double(width * height)

        struct ScoredBucket {
            let color: Color
            let coverage: Double
            let score: Double
        }

        let scored: [ScoredBucket] = buckets.compactMap { (_, bucket) in
            guard bucket.count > 0 else { return nil }
            let red = Double(bucket.totalR) / Double(bucket.count) / 255.0
            let green = Double(bucket.totalG) / Double(bucket.count) / 255.0
            let blue = Double(bucket.totalB) / Double(bucket.count) / 255.0

            let maxChannel = max(red, max(green, blue))
            let minChannel = min(red, min(green, blue))
            let saturation = maxChannel == 0 ? 0 : (maxChannel - minChannel) / maxChannel
            let brightness = maxChannel
            let coverage = Double(bucket.count) / totalPixels

            // Penalize tiny, highly saturated regions that are likely logos/accents.
            let saturationPenalty = saturation * 0.6
            let brightnessPenalty = (brightness < 0.12 || brightness > 0.95) ? 0.35 : 0.0
            let score = coverage * max(0.05, 1.0 - saturationPenalty - brightnessPenalty)

            return ScoredBucket(
                color: Color(.sRGB, red: red, green: green, blue: blue),
                coverage: coverage,
                score: score
            )
        }

        let rankedByScore = scored.sorted { $0.score > $1.score }
        let rankedByCoverage = scored.sorted { $0.coverage > $1.coverage }

        let primary = rankedByScore.first?.color
        let confidence = rankedByScore.first?.coverage ?? 0

        var suggestions: [Color] = []
        for candidate in rankedByCoverage {
            if suggestions.count >= 3 {
                break
            }
            let ui = UIColor(candidate.color)
            if !suggestions.contains(where: { UIColor($0).isNear(ui) }) {
                suggestions.append(candidate.color)
            }
        }

        return Analysis(primaryColor: primary, suggestedColors: suggestions, confidence: confidence)
    }

    private static func readableCGImage(from image: UIImage) -> CGImage? {
        if let cgImage = image.cgImage {
            return cgImage
        }

        if let ciImage = image.ciImage {
            let context = CIContext(options: nil)
            return context.createCGImage(ciImage, from: ciImage.extent)
        }

        guard image.size.width > 0, image.size.height > 0 else {
            return nil
        }

        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        let rendered = renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: image.size))
        }
        return rendered.cgImage
    }

    private static func cropToLikelyCardRegion(from cgImage: CGImage) -> CGImage? {
        let request = VNDetectRectanglesRequest()
        request.maximumObservations = 1
        request.minimumAspectRatio = 0.35
        request.maximumAspectRatio = 1.2
        request.minimumSize = 0.25
        request.quadratureTolerance = 20

        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        do {
            try handler.perform([request])
        } catch {
            return nil
        }

        guard let rect = request.results?.first else { return nil }

        let imageWidth = CGFloat(cgImage.width)
        let imageHeight = CGFloat(cgImage.height)
        let box = rect.boundingBox
        let cropRect = CGRect(
            x: box.origin.x * imageWidth,
            y: (1 - box.origin.y - box.height) * imageHeight,
            width: box.width * imageWidth,
            height: box.height * imageHeight
        ).integral

        guard cropRect.width > 10, cropRect.height > 10 else { return nil }
        return cgImage.cropping(to: cropRect)
    }
}

private extension UIColor {
    func isNear(_ other: UIColor, tolerance: CGFloat = 0.08) -> Bool {
        var r1: CGFloat = 0
        var g1: CGFloat = 0
        var b1: CGFloat = 0
        var a1: CGFloat = 0
        var r2: CGFloat = 0
        var g2: CGFloat = 0
        var b2: CGFloat = 0
        var a2: CGFloat = 0

        guard self.getRed(&r1, green: &g1, blue: &b1, alpha: &a1),
              other.getRed(&r2, green: &g2, blue: &b2, alpha: &a2) else {
            return false
        }

        return abs(r1 - r2) < tolerance
            && abs(g1 - g2) < tolerance
            && abs(b1 - b2) < tolerance
    }
}

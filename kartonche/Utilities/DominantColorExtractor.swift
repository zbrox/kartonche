//
//  DominantColorExtractor.swift
//  kartonche
//

import SwiftUI
import UIKit

/// Extracts the dominant color from a UIImage using pixel-bucketed color quantization
enum DominantColorExtractor {

    /// Extracts the dominant color from an image.
    ///
    /// Downscales the image, quantizes pixel colors into buckets, picks the most frequent bucket,
    /// then averages original RGB values within that bucket for a smoother result.
    ///
    /// - Parameter image: The source image
    /// - Returns: The dominant color, or `nil` if the image cannot be read
    static func extractDominantColor(from image: UIImage) -> Color? {
        guard let cgImage = image.cgImage else { return nil }

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
        ) else { return nil }

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

        guard let winner = buckets.max(by: { $0.value.count < $1.value.count }) else { return nil }

        let avg = winner.value
        let red = Double(avg.totalR) / Double(avg.count) / 255.0
        let green = Double(avg.totalG) / Double(avg.count) / 255.0
        let blue = Double(avg.totalB) / Double(avg.count) / 255.0

        return Color(.sRGB, red: red, green: green, blue: blue)
    }
}

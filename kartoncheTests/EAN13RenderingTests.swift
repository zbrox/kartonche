//
//  EAN13RenderingTests.swift
//  kartoncheTests
//

import Testing
import UIKit
@testable import kartonche

@MainActor
struct EAN13RenderingTests {

    @Test func returnsNilForNon13DigitInput() {
        #expect(BarcodeGenerator.renderEAN13(digits: "123456789012", size: CGSize(width: 200, height: 100)) == nil)
        #expect(BarcodeGenerator.renderEAN13(digits: "12345678901234", size: CGSize(width: 200, height: 100)) == nil)
        #expect(BarcodeGenerator.renderEAN13(digits: "", size: CGSize(width: 200, height: 100)) == nil)
    }

    @Test func returnsNilForNonNumericInput() {
        #expect(BarcodeGenerator.renderEAN13(digits: "123456789012A", size: CGSize(width: 200, height: 100)) == nil)
        #expect(BarcodeGenerator.renderEAN13(digits: "abcdefghijklm", size: CGSize(width: 200, height: 100)) == nil)
    }

    @Test func producesImageOfRequestedSize() {
        let size = CGSize(width: 300, height: 150)
        let image = BarcodeGenerator.renderEAN13(digits: "1234567890123", size: size)
        #expect(image != nil)
        #expect(image!.size.width == size.width)
        #expect(image!.size.height == size.height)
    }

    @Test func producesNonEmptyImageData() {
        let image = BarcodeGenerator.renderEAN13(digits: "1234567890123", size: CGSize(width: 200, height: 100))
        #expect(image != nil)
        let data = image!.pngData()
        #expect(data != nil)
        #expect(!data!.isEmpty)
    }

    @Test func quietZonesAreWhite() {
        let size = CGSize(width: 400, height: 200)
        guard let image = BarcodeGenerator.renderEAN13(digits: "1234567890123", size: size),
              let cgImage = image.cgImage else {
            Issue.record("Failed to render image")
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            Issue.record("Failed to create context")
            return
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        // Sample a pixel in the left quiet zone (first few columns, upper third)
        let midY = height / 3
        let leftQuietX = 2
        let offset = midY * bytesPerRow + leftQuietX * bytesPerPixel
        let r = pixelData[offset]
        let g = pixelData[offset + 1]
        let b = pixelData[offset + 2]
        #expect(r == 255 && g == 255 && b == 255, "Left quiet zone pixel should be white, got (\(r),\(g),\(b))")
    }

    @Test func startGuardHasBlackPixels() {
        let size = CGSize(width: 400, height: 200)
        guard let image = BarcodeGenerator.renderEAN13(digits: "1234567890123", size: size),
              let cgImage = image.cgImage else {
            Issue.record("Failed to render image")
            return
        }

        let width = cgImage.width
        let height = cgImage.height
        let bytesPerPixel = 4
        let bytesPerRow = width * bytesPerPixel
        var pixelData = [UInt8](repeating: 0, count: height * bytesPerRow)

        guard let context = CGContext(
            data: &pixelData,
            width: width,
            height: height,
            bitsPerComponent: 8,
            bytesPerRow: bytesPerRow,
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue
        ) else {
            Issue.record("Failed to create context")
            return
        }
        context.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))

        let midY = height / 3
        var foundBlack = false
        let searchStart = width / 8
        let searchEnd = width / 3
        for x in searchStart..<searchEnd {
            let offset = midY * bytesPerRow + x * bytesPerPixel
            if pixelData[offset] == 0 && pixelData[offset + 1] == 0 && pixelData[offset + 2] == 0 {
                foundBlack = true
                break
            }
        }
        #expect(foundBlack, "Should find black pixels in the start guard area")
    }

    @Test func consistentOutput() {
        let size = CGSize(width: 200, height: 100)
        let image1 = BarcodeGenerator.renderEAN13(digits: "1234567890123", size: size)
        let image2 = BarcodeGenerator.renderEAN13(digits: "1234567890123", size: size)
        #expect(image1 != nil)
        #expect(image2 != nil)
        let data1 = image1!.pngData()
        let data2 = image2!.pngData()
        #expect(data1 == data2)
    }
}

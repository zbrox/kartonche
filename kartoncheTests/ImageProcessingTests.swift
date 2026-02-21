//
//  ImageProcessingTests.swift
//  kartoncheTests
//

import XCTest
import SwiftUI
@testable import kartonche

/// Integration tests for the Quick Scan image processing path.
///
/// Barcode scanning from programmatic images is tested in PhotoBarcodeScannerTests.
/// These tests focus on color extraction integration and the independence of the two paths.
@MainActor
final class ImageProcessingTests: XCTestCase {

    // MARK: - Helpers

    private static func makeSolidImage(color: UIColor, size: CGSize = CGSize(width: 200, height: 200)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private static func rgbComponents(of color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return (r, g, b)
    }

    // MARK: - Color extraction integration

    func testColorExtractionFromGreenImage() {
        let image = Self.makeSolidImage(color: UIColor(red: 0.2, green: 0.8, blue: 0.1, alpha: 1.0))
        let color = DominantColorExtractor.extractDominantColor(from: image)

        XCTAssertNotNil(color, "Should extract color from green image")
        if let components = Self.rgbComponents(of: color!) {
            XCTAssertLessThan(components.red, 0.4)
            XCTAssertGreaterThan(components.green, 0.6)
            XCTAssertLessThan(components.blue, 0.3)
        }
    }

    func testColorExtractionSucceedsForPlainImage() {
        let image = Self.makeSolidImage(color: UIColor(red: 1.0, green: 0.5, blue: 0.0, alpha: 1.0))
        let color = DominantColorExtractor.extractDominantColor(from: image)
        XCTAssertNotNil(color, "Color extraction should succeed on a plain image")
    }

    func testColorExtractionReturnsNilForEmptyImage() {
        let color = DominantColorExtractor.extractDominantColor(from: UIImage())
        XCTAssertNil(color, "Should return nil for an image without a CGImage")
    }

    func testExtractedColorDerivedContrastingText() {
        // Dark image -> should get white contrasting text
        let darkImage = Self.makeSolidImage(color: UIColor(red: 0.1, green: 0.1, blue: 0.3, alpha: 1.0))
        let darkColor = DominantColorExtractor.extractDominantColor(from: darkImage)
        XCTAssertNotNil(darkColor)

        let textColor = darkColor!.contrastingTextColor()
        let components = Self.rgbComponents(of: textColor)
        // White text has all channels > 0.9
        XCTAssertNotNil(components)
        XCTAssertGreaterThan(components!.red, 0.9, "Dark background should get white text")

        // Light image -> should get black contrasting text
        let lightImage = Self.makeSolidImage(color: UIColor(red: 0.9, green: 0.9, blue: 0.7, alpha: 1.0))
        let lightColor = DominantColorExtractor.extractDominantColor(from: lightImage)
        XCTAssertNotNil(lightColor)

        let lightTextColor = lightColor!.contrastingTextColor()
        let lightComponents = Self.rgbComponents(of: lightTextColor)
        XCTAssertNotNil(lightComponents)
        XCTAssertLessThan(lightComponents!.red, 0.1, "Light background should get black text")
    }
}

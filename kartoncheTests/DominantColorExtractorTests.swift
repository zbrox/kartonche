//
//  DominantColorExtractorTests.swift
//  kartoncheTests
//

import XCTest
import SwiftUI
@testable import kartonche

@MainActor
final class DominantColorExtractorTests: XCTestCase {

    // MARK: - Helpers

    /// Creates a solid-color UIImage of the given size
    private func solidImage(color: UIColor, size: CGSize = CGSize(width: 100, height: 100)) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        color.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    /// Creates an image that is mostly `dominant` with a small `accent` patch in the top-left corner
    private func mostlyImage(dominant: UIColor, accent: UIColor, accentFraction: CGFloat = 0.1) -> UIImage {
        let size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContextWithOptions(size, true, 1.0)
        dominant.setFill()
        UIRectFill(CGRect(origin: .zero, size: size))
        accent.setFill()
        let accentSide = sqrt(accentFraction) * 100
        UIRectFill(CGRect(x: 0, y: 0, width: accentSide, height: accentSide))
        let image = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        return image
    }

    private func rgbComponents(of color: Color) -> (red: CGFloat, green: CGFloat, blue: CGFloat)? {
        let uiColor = UIColor(color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        guard uiColor.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        return (r, g, b)
    }

    // MARK: - Tests

    func testSolidRedImageExtractsNearRed() {
        let image = solidImage(color: .red)
        let result = DominantColorExtractor.extractDominantColor(from: image)

        XCTAssertNotNil(result, "Should extract a color from a solid red image")
        guard let components = rgbComponents(of: result!) else {
            XCTFail("Could not read RGB components")
            return
        }
        XCTAssertGreaterThan(components.red, 0.7, "Red channel should be high")
        XCTAssertLessThan(components.green, 0.3, "Green channel should be low")
        XCTAssertLessThan(components.blue, 0.3, "Blue channel should be low")
    }

    func testMostlyBlueImageExtractsNearBlue() {
        let image = mostlyImage(dominant: .blue, accent: .red, accentFraction: 0.05)
        let result = DominantColorExtractor.extractDominantColor(from: image)

        XCTAssertNotNil(result, "Should extract a color from a mostly-blue image")
        guard let components = rgbComponents(of: result!) else {
            XCTFail("Could not read RGB components")
            return
        }
        XCTAssertLessThan(components.red, 0.3, "Red channel should be low")
        XCTAssertLessThan(components.green, 0.3, "Green channel should be low")
        XCTAssertGreaterThan(components.blue, 0.7, "Blue channel should be high")
    }

    func testImageWithoutCGImageReturnsNil() {
        // UIImage with no backing CGImage
        let emptyImage = UIImage()
        let result = DominantColorExtractor.extractDominantColor(from: emptyImage)
        XCTAssertNil(result, "Should return nil for an image without a readable pixel buffer")
    }
}

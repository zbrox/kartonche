//
//  PhotoBarcodeScannerTests.swift
//  kartoncheTests
//
//  Created on 6.2.2026.
//

import Testing
import UIKit
import Vision
import CoreImage
@testable import kartonche

struct PhotoBarcodeScannerTests {
    
    // NOTE: Testing barcode scanning with programmatically generated images is unreliable
    // because Core Image's barcode generators may not produce images that Vision can scan back
    // These tests would need real barcode images for accurate testing
    // For now, we test error cases which are deterministic
    
    @Test func testInvalidImage() async throws {
        // Create an empty/invalid image
        let image = UIImage()
        
        do {
            _ = try await PhotoBarcodeScanner.scanBarcodes(from: image)
            Issue.record("Expected invalidImage error")
        } catch PhotoBarcodeScanner.ScanError.invalidImage {
            // Expected error
        } catch {
            Issue.record("Unexpected error: \(error)")
        }
    }

    @Test func testCIBackedImageIsNotRejectedAsInvalid() async throws {
        let ciImage = CIImage(color: CIColor(red: 0, green: 0, blue: 1, alpha: 1))
            .cropped(to: CGRect(x: 0, y: 0, width: 128, height: 128))
        let image = UIImage(ciImage: ciImage)

        do {
            _ = try await PhotoBarcodeScanner.scanBarcodes(from: image)
        } catch PhotoBarcodeScanner.ScanError.invalidImage {
            Issue.record("CI-backed images from photo library should not be rejected as invalid")
        } catch {
            // noBarcodesFound or processingFailed are acceptable here;
            // this test validates image readability path, not detection success.
        }
    }

    // NOTE: Testing noBarcodesFound with programmatically generated images
    // is unreliable - Vision may find false positives in solid color images
    // Manual testing with real photos is more reliable for this case
}

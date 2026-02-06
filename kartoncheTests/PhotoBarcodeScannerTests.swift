//
//  PhotoBarcodeScannerTests.swift
//  kartoncheTests
//
//  Created on 6.2.2026.
//

import Testing
import UIKit
import Vision
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
    
    // NOTE: Testing noBarcodesFound with programmatically generated images
    // is unreliable - Vision may find false positives in solid color images
    // Manual testing with real photos is more reliable for this case
}

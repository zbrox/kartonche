//
//  PhotoBarcodeScanner.swift
//  kartonche
//
//  Created on 6.2.2026.
//

import UIKit
import Vision
import VisionKit

/// Utility for scanning barcodes from static images using Vision framework
class PhotoBarcodeScanner {
    
    enum ScanError: LocalizedError {
        case invalidImage
        case noBarcodesFound
        case processingFailed(Error)
        
        var errorDescription: String? {
            switch self {
            case .invalidImage:
                return String(localized: "Invalid image format")
            case .noBarcodesFound:
                return String(localized: "No barcodes found in image")
            case .processingFailed(let error):
                return String(localized: "Scanning failed: \(error.localizedDescription)")
            }
        }
    }
    
    /// Scans an image for barcodes
    /// - Parameter image: The UIImage to scan
    /// - Returns: Array of detected barcodes
    /// - Throws: ScanError if scanning fails
    static func scanBarcodes(from image: UIImage) async throws -> [ScannedBarcode] {
        guard let cgImage = image.cgImage else {
            throw ScanError.invalidImage
        }
        
        return try await withCheckedThrowingContinuation { continuation in
            let resumeLock = NSLock()
            var didResume = false

            func resumeOnce(_ result: Result<[ScannedBarcode], Error>) {
                resumeLock.lock()
                defer { resumeLock.unlock() }
                guard !didResume else { return }
                didResume = true

                switch result {
                case .success(let barcodes):
                    continuation.resume(returning: barcodes)
                case .failure(let error):
                    continuation.resume(throwing: error)
                }
            }

            let request = VNDetectBarcodesRequest { request, error in
                if let error = error {
                    resumeOnce(.failure(ScanError.processingFailed(error)))
                    return
                }
                
                guard let results = request.results as? [VNBarcodeObservation], !results.isEmpty else {
                    resumeOnce(.failure(ScanError.noBarcodesFound))
                    return
                }
                
                let barcodes = results.compactMap { observation -> ScannedBarcode? in
                    guard let payloadString = observation.payloadStringValue else {
                        return nil
                    }
                    return ScannedBarcode(
                        data: payloadString,
                        symbology: observation.symbology
                    )
                }
                
                if barcodes.isEmpty {
                    resumeOnce(.failure(ScanError.noBarcodesFound))
                } else {
                    resumeOnce(.success(barcodes))
                }
            }
            
            // Configure supported symbologies (same as live scanner)
            request.symbologies = [
                .qr,
                .code128,
                .ean13,
                .pdf417,
                .aztec
            ]
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            
            do {
                try handler.perform([request])
            } catch {
                resumeOnce(.failure(ScanError.processingFailed(error)))
            }
        }
    }
}

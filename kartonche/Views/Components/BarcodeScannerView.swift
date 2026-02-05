//
//  BarcodeScannerView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import VisionKit

/// SwiftUI wrapper for VisionKit's DataScannerViewController
/// Scans barcodes using the device camera
struct BarcodeScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedCode: String?
    let onDismiss: () -> Void
    
    func makeUIViewController(context: Context) -> DataScannerViewController {
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
            .barcode(symbologies: [
                .qr,
                .code128,
                .ean13,
                .pdf417,
                .aztec
            ])
        ]
        
        let scanner = DataScannerViewController(
            recognizedDataTypes: recognizedDataTypes,
            qualityLevel: .balanced,
            recognizesMultipleItems: false,
            isHighFrameRateTrackingEnabled: true,
            isPinchToZoomEnabled: true,
            isGuidanceEnabled: true,
            isHighlightingEnabled: true
        )
        
        scanner.delegate = context.coordinator
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        // No updates needed
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedCode: $scannedCode, onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var scannedCode: String?
        let onDismiss: () -> Void
        
        init(scannedCode: Binding<String?>, onDismiss: @escaping () -> Void) {
            self._scannedCode = scannedCode
            self.onDismiss = onDismiss
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                if let payloadString = barcode.payloadStringValue {
                    scannedCode = payloadString
                    onDismiss()
                }
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            // Auto-scan first barcode detected
            for item in addedItems {
                if case .barcode(let barcode) = item {
                    if let payloadString = barcode.payloadStringValue {
                        scannedCode = payloadString
                        onDismiss()
                        return
                    }
                }
            }
        }
    }
    
    /// Check if device supports barcode scanning
    static var isSupported: Bool {
        DataScannerViewController.isSupported && 
        DataScannerViewController.isAvailable
    }
}

#Preview {
    BarcodeScannerView(
        scannedCode: .constant(nil),
        onDismiss: {}
    )
}

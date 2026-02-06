//
//  BarcodeScannerView.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import SwiftUI
import Vision
import VisionKit

struct ScannedBarcode: Equatable {
    let data: String
    let symbology: VNBarcodeSymbology
}

struct BarcodeScannerView: UIViewControllerRepresentable {
    
    @Binding var scannedBarcode: ScannedBarcode?
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
        
        // Start scanning immediately
        try? scanner.startScanning()
        
        return scanner
    }
    
    func updateUIViewController(_ uiViewController: DataScannerViewController, context: Context) {
        if !uiViewController.isScanning {
            try? uiViewController.startScanning()
        }
    }
    
    static func dismantleUIViewController(_ uiViewController: DataScannerViewController, coordinator: Coordinator) {
        uiViewController.stopScanning()
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(scannedBarcode: $scannedBarcode, onDismiss: onDismiss)
    }
    
    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var scannedBarcode: ScannedBarcode?
        let onDismiss: () -> Void
        
        init(scannedBarcode: Binding<ScannedBarcode?>, onDismiss: @escaping () -> Void) {
            self._scannedBarcode = scannedBarcode
            self.onDismiss = onDismiss
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            switch item {
            case .barcode(let barcode):
                if let payloadString = barcode.payloadStringValue {
                    scannedBarcode = ScannedBarcode(
                        data: payloadString,
                        symbology: barcode.observation.symbology
                    )
                    onDismiss()
                }
            default:
                break
            }
        }
        
        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            for item in addedItems {
                if case .barcode(let barcode) = item {
                    if let payloadString = barcode.payloadStringValue {
                        scannedBarcode = ScannedBarcode(
                            data: payloadString,
                            symbology: barcode.observation.symbology
                        )
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
        scannedBarcode: .constant(nil),
        onDismiss: {}
    )
}

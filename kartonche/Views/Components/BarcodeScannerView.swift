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
    var onScanWithPhoto: ((ScannedBarcode, UIImage?) -> Void)?

    func makeUIViewController(context: Context) -> DataScannerViewController {
        let recognizedDataTypes: Set<DataScannerViewController.RecognizedDataType> = [
            .barcode(symbologies: [
                .qr,
                .code128,
                .ean13,
                .pdf417,
                .aztec,
                .code39,
                .code39Checksum,
                .code39FullASCII,
                .code39FullASCIIChecksum,
                .upce,
                .i2of5,
                .i2of5Checksum,
                .dataMatrix,
                .ean8,
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
        context.coordinator.scanner = scanner

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
        Coordinator(
            scannedBarcode: $scannedBarcode,
            onDismiss: onDismiss,
            onScanWithPhoto: onScanWithPhoto
        )
    }

    class Coordinator: NSObject, DataScannerViewControllerDelegate {
        @Binding var scannedBarcode: ScannedBarcode?
        let onDismiss: () -> Void
        let onScanWithPhoto: ((ScannedBarcode, UIImage?) -> Void)?
        weak var scanner: DataScannerViewController?

        init(
            scannedBarcode: Binding<ScannedBarcode?>,
            onDismiss: @escaping () -> Void,
            onScanWithPhoto: ((ScannedBarcode, UIImage?) -> Void)?
        ) {
            self._scannedBarcode = scannedBarcode
            self.onDismiss = onDismiss
            self.onScanWithPhoto = onScanWithPhoto
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didTapOn item: RecognizedItem) {
            handleRecognizedItem(item, from: dataScanner)
        }

        func dataScanner(_ dataScanner: DataScannerViewController, didAdd addedItems: [RecognizedItem], allItems: [RecognizedItem]) {
            guard let item = addedItems.first else { return }
            handleRecognizedItem(item, from: dataScanner)
        }

        private func handleRecognizedItem(_ item: RecognizedItem, from dataScanner: DataScannerViewController) {
            guard case .barcode(let barcode) = item,
                  let payloadString = barcode.payloadStringValue else { return }

            let scanned = ScannedBarcode(
                data: payloadString,
                symbology: barcode.observation.symbology
            )

            if let onScanWithPhoto {
                dataScanner.stopScanning()
                Task { @MainActor in
                    let photo = try? await dataScanner.capturePhoto()
                    onScanWithPhoto(scanned, photo)
                }
            } else {
                scannedBarcode = scanned
                onDismiss()
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

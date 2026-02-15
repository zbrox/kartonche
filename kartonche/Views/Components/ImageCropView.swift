//
//  ImageCropView.swift
//  kartonche
//
//  Created on 2026-02-15.
//

import SwiftUI
import UIKit

/// Interactive crop view that lets the user pan and zoom an image within a fixed strip-ratio window.
struct ImageCropView: View {
    let image: UIImage
    let onCrop: (Data) -> Void

    @Environment(\.dismiss) private var dismiss

    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero
    @State private var viewWidth: CGFloat = 0

    private let aspectRatio = WalletPassConfiguration.stripAspectRatio

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let cropWidth = geometry.size.width
                let cropHeight = cropWidth / aspectRatio
                let cropRect = CGRect(
                    x: 0,
                    y: (geometry.size.height - cropHeight) / 2,
                    width: cropWidth,
                    height: cropHeight
                )

                ZStack {
                    Color.black

                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(
                            width: cropWidth * scale,
                            height: cropWidth * scale / imageAspectRatio
                        )
                        .offset(offset)
                        .position(x: geometry.size.width / 2, y: geometry.size.height / 2)
                        .gesture(dragGesture(cropRect: cropRect, cropWidth: cropWidth))
                        .gesture(magnifyGesture(cropRect: cropRect, cropWidth: cropWidth))

                    // Dimming overlay with transparent crop window
                    CropOverlay(cropRect: cropRect)
                        .allowsHitTesting(false)
                }
                .onAppear { viewWidth = cropWidth }
                .onChange(of: geometry.size) { viewWidth = geometry.size.width }
            }
            .ignoresSafeArea()
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.hidden, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) {
                        let data = renderCroppedImage(cropWidth: viewWidth)
                        onCrop(data)
                        dismiss()
                    }
                    .foregroundStyle(.white)
                }
            }
        }
    }

    // MARK: - Gestures

    private func dragGesture(cropRect: CGRect, cropWidth: CGFloat) -> some Gesture {
        DragGesture()
            .onChanged { value in
                offset = CGSize(
                    width: lastOffset.width + value.translation.width,
                    height: lastOffset.height + value.translation.height
                )
            }
            .onEnded { _ in
                offset = clampedOffset(offset, cropRect: cropRect, cropWidth: cropWidth)
                lastOffset = offset
            }
    }

    private func magnifyGesture(cropRect: CGRect, cropWidth: CGFloat) -> some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let proposed = lastScale * value.magnification
                scale = max(proposed, minimumScale(cropWidth: cropWidth))
            }
            .onEnded { _ in
                scale = max(scale, minimumScale(cropWidth: cropWidth))
                lastScale = scale
                offset = clampedOffset(offset, cropRect: cropRect, cropWidth: cropWidth)
                lastOffset = offset
            }
    }

    // MARK: - Constraints

    private var imageAspectRatio: CGFloat {
        guard image.size.height > 0 else { return 1 }
        return image.size.width / image.size.height
    }

    /// Minimum scale that ensures the image fills the crop rect.
    private func minimumScale(cropWidth: CGFloat) -> CGFloat {
        let cropHeight = cropWidth / aspectRatio
        let imageDisplayWidth = cropWidth
        let imageDisplayHeight = cropWidth / imageAspectRatio

        let scaleForWidth: CGFloat = cropWidth / imageDisplayWidth   // always 1
        let scaleForHeight: CGFloat = cropHeight / imageDisplayHeight

        return max(scaleForWidth, scaleForHeight)
    }

    /// Clamps offset so the image always covers the crop rect.
    private func clampedOffset(_ proposed: CGSize, cropRect: CGRect, cropWidth: CGFloat) -> CGSize {
        let imgW = cropWidth * scale
        let imgH = cropWidth * scale / imageAspectRatio

        let maxDx = max(0, (imgW - cropRect.width) / 2)
        let maxDy = max(0, (imgH - cropRect.height) / 2)

        return CGSize(
            width: min(max(proposed.width, -maxDx), maxDx),
            height: min(max(proposed.height, -maxDy), maxDy)
        )
    }

    // MARK: - Rendering

    /// Computes the rect to draw the full image into so that the crop window maps to the output bitmap.
    ///
    /// Mirrors the on-screen layout: image is `cropWidth * scale` wide, centered with `offset`,
    /// then scaled up to output pixel size. The crop window occupies the full output rect.
    static func cropDrawRect(
        imageAspectRatio: CGFloat,
        cropAspectRatio: CGFloat,
        scale: CGFloat,
        offset: CGSize,
        cropWidth: CGFloat,
        outputSize: CGSize
    ) -> CGRect {
        let cropHeight = cropWidth / cropAspectRatio
        let renderScale = outputSize.width / cropWidth

        let imgW = cropWidth * scale
        let imgH = cropWidth * scale / imageAspectRatio

        let drawW = imgW * renderScale
        let drawH = imgH * renderScale
        let drawX = (cropWidth / 2 + offset.width - imgW / 2) * renderScale
        let drawY = (cropHeight / 2 + offset.height - imgH / 2) * renderScale

        return CGRect(x: drawX, y: drawY, width: drawW, height: drawH)
    }

    private func renderCroppedImage(cropWidth: CGFloat) -> Data {
        let pixelWidth = WalletPassConfiguration.stripWidth * WalletPassConfiguration.stripScale
        let pixelHeight = WalletPassConfiguration.stripHeight * WalletPassConfiguration.stripScale
        let outputSize = CGSize(width: pixelWidth, height: pixelHeight)

        let drawRect = Self.cropDrawRect(
            imageAspectRatio: imageAspectRatio,
            cropAspectRatio: aspectRatio,
            scale: scale,
            offset: offset,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        let renderer = UIGraphicsImageRenderer(size: outputSize)
        let rendered = renderer.image { _ in
            image.draw(in: drawRect)
        }

        return rendered.jpegData(compressionQuality: 0.85) ?? Data()
    }
}

// MARK: - Crop Overlay

/// Draws a semi-transparent overlay with a clear rectangular cutout.
private struct CropOverlay: View {
    let cropRect: CGRect

    var body: some View {
        GeometryReader { geometry in
            let fullRect = CGRect(origin: .zero, size: geometry.size)
            Canvas { context, _ in
                context.fill(Path(fullRect), with: .color(.black.opacity(0.5)))
                context.blendMode = .destinationOut
                context.fill(Path(cropRect), with: .color(.white))
            }
            .compositingGroup()

            // Crop border
            Rectangle()
                .stroke(.white.opacity(0.6), lineWidth: 1)
                .frame(width: cropRect.width, height: cropRect.height)
                .position(x: cropRect.midX, y: cropRect.midY)
        }
    }
}

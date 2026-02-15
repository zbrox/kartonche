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
                        let data = renderCroppedImage()
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

    private func renderCroppedImage() -> Data {
        let pixelWidth = WalletPassConfiguration.stripWidth * WalletPassConfiguration.stripScale
        let pixelHeight = WalletPassConfiguration.stripHeight * WalletPassConfiguration.stripScale
        let outputSize = CGSize(width: pixelWidth, height: pixelHeight)

        let renderer = UIGraphicsImageRenderer(size: outputSize)
        let rendered = renderer.image { _ in
            // Determine how the image is displayed on screen.
            // The image is drawn centered in the full geometry, scaled by `scale`,
            // with aspect-fill base fitting to the crop width.
            // We need to figure out which portion of the source image is visible in the crop rect.
            let sourceW = image.size.width
            let sourceH = image.size.height

            // At scale=1, the image fills the crop width with aspect-fill
            // imageDisplayWidth = cropWidth, imageDisplayHeight = cropWidth / imageAspectRatio
            // The crop rect has cropHeight = cropWidth / aspectRatio
            // At scale=s, displayed size = cropWidth*s × (cropWidth*s / imageAspect)
            // The visible region (crop rect) is centered at (center + offset) in image-display space.

            // Fraction of displayed image that the crop rect covers:
            // We don't have cropWidth here, but the ratio is the same regardless of screen size
            // since everything is proportional to cropWidth.
            // displayedW = cropWidth * scale, displayedH = cropWidth * scale / imageAspect
            // cropW = cropWidth, cropH = cropWidth / aspectRatio
            // visibleFractionW = cropWidth / (cropWidth * scale) = 1/scale
            // visibleFractionH = (cropWidth/aspectRatio) / (cropWidth*scale/imageAspect) = imageAspect / (aspectRatio * scale)

            let visibleFractionW = 1.0 / scale
            let visibleFractionH = imageAspectRatio / (aspectRatio * scale)

            // Offset as fraction of displayed size: offset / displayedSize
            // offsetFractionX = offset.width / (cropWidth * scale) = offset.width / (cropWidth * scale)
            // But since we don't have cropWidth, we use: offset fraction = offset.width / (displayedW)
            // We can set cropWidth = 1 for normalization since all ratios cancel.
            let offsetFractionX = offset.width / scale  // offset.width / (1 * scale)
            let offsetFractionY = offset.height / scale

            // Source rect center (0.5 = center of image) shifted by offset fraction
            // Negative offset means image moved left → we see more of the right side → centerX increases
            let centerFractionX = 0.5 - offsetFractionX
            let centerFractionY = 0.5 - offsetFractionY

            let srcX = (centerFractionX - visibleFractionW / 2) * sourceW
            let srcY = (centerFractionY - visibleFractionH / 2) * sourceH
            let srcW = visibleFractionW * sourceW
            let srcH = visibleFractionH * sourceH

            let sourceRect = CGRect(x: srcX, y: srcY, width: srcW, height: srcH)

            if let cgImage = image.cgImage?.cropping(to: sourceRect) {
                UIImage(cgImage: cgImage).draw(in: CGRect(origin: .zero, size: outputSize))
            } else {
                // Fallback: draw the whole image scaled to fit
                image.draw(in: CGRect(origin: .zero, size: outputSize))
            }
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

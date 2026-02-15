//
//  ImageCropViewTests.swift
//  kartoncheTests
//
//  Created on 2026-02-15.
//

import Testing
import UIKit
@testable import kartonche

@MainActor
struct ImageCropViewTests {

    private let outputSize = CGSize(width: 1125, height: 369)
    private let cropAspectRatio = WalletPassConfiguration.stripAspectRatio

    // MARK: - Default position (scale=1, offset=zero)

    @Test func defaultPositionLandscapeImage() {
        // 4000x3000 landscape image, cropWidth=390
        let imageAspect: CGFloat = 4000.0 / 3000.0
        let cropWidth: CGFloat = 390

        let rect = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: 1.0,
            offset: .zero,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        // At scale=1, image width == cropWidth, so drawW == outputSize.width
        #expect(abs(rect.width - outputSize.width) < 0.01)
        // drawX should be 0 (image left-aligned with crop)
        #expect(abs(rect.origin.x) < 0.01)
        // Image is taller than crop → drawH > outputSize.height, centered vertically
        #expect(rect.height > outputSize.height)
    }

    @Test func defaultPositionPortraitImage() {
        // 3000x4000 portrait image, cropWidth=390
        let imageAspect: CGFloat = 3000.0 / 4000.0
        let cropWidth: CGFloat = 390

        let rect = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: 1.0,
            offset: .zero,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        // At scale=1, drawW == outputSize.width
        #expect(abs(rect.width - outputSize.width) < 0.01)
        // Portrait image is much taller → drawH >> outputSize.height
        #expect(rect.height > outputSize.height)
        // Image should be vertically centered around crop center
        let imgCenterY = rect.origin.y + rect.height / 2
        let cropCenterY = outputSize.height / 2
        #expect(abs(imgCenterY - cropCenterY) < 0.01)
    }

    // MARK: - Zoom

    @Test func zoomScalesProportionally() {
        let imageAspect: CGFloat = 4000.0 / 3000.0
        let cropWidth: CGFloat = 390
        let zoomScale: CGFloat = 2.0

        let rectDefault = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: 1.0,
            offset: .zero,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        let rectZoomed = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: zoomScale,
            offset: .zero,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        // Zoomed draw rect should be 2x in each dimension
        #expect(abs(rectZoomed.width - rectDefault.width * zoomScale) < 0.01)
        #expect(abs(rectZoomed.height - rectDefault.height * zoomScale) < 0.01)
    }

    // MARK: - Pan

    @Test func panShiftsDrawRect() {
        let imageAspect: CGFloat = 4000.0 / 3000.0
        let cropWidth: CGFloat = 390
        let panOffset = CGSize(width: -50, height: 20)

        let rectDefault = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: 1.5,
            offset: .zero,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        let rectPanned = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: 1.5,
            offset: panOffset,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        let renderScale = outputSize.width / cropWidth

        // Draw rect shifts by offset * renderScale
        #expect(abs(rectPanned.origin.x - (rectDefault.origin.x + panOffset.width * renderScale)) < 0.01)
        #expect(abs(rectPanned.origin.y - (rectDefault.origin.y + panOffset.height * renderScale)) < 0.01)
        // Size unchanged by pan
        #expect(abs(rectPanned.width - rectDefault.width) < 0.01)
        #expect(abs(rectPanned.height - rectDefault.height) < 0.01)
    }

    // MARK: - Square image

    @Test func squareImageCenteredCorrectly() {
        let imageAspect: CGFloat = 1.0
        let cropWidth: CGFloat = 390

        let rect = ImageCropView.cropDrawRect(
            imageAspectRatio: imageAspect,
            cropAspectRatio: cropAspectRatio,
            scale: 1.0,
            offset: .zero,
            cropWidth: cropWidth,
            outputSize: outputSize
        )

        // Square image: drawW == drawH == outputSize.width (since imageAspect == 1)
        #expect(abs(rect.width - outputSize.width) < 0.01)
        #expect(abs(rect.height - outputSize.width) < 0.01)
        // Horizontally aligned
        #expect(abs(rect.origin.x) < 0.01)
        // Vertically centered
        let imgCenterY = rect.origin.y + rect.height / 2
        let cropCenterY = outputSize.height / 2
        #expect(abs(imgCenterY - cropCenterY) < 0.01)
    }
}

//
//  WalletPassGenerator.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import Foundation
import SwiftUI
import UIKit
import Crypto
@_spi(CMS) import X509
import SwiftASN1
import _CryptoExtras
import ZIPFoundation

enum WalletPassGeneratorError: LocalizedError {
    case unsupportedBarcodeType
    case missingResource(String)
    case invalidCertificate
    case invalidPrivateKey
    case signingFailed(String)
    case archiveFailed(String)
    case colorConversionFailed

    var errorDescription: String? {
        switch self {
        case .unsupportedBarcodeType:
            return String(localized: "This barcode format is not supported by Apple Wallet")
        case .missingResource(let name):
            return "Missing resource: \(name)"
        case .invalidCertificate:
            return "Invalid pass signing certificate"
        case .invalidPrivateKey:
            return "Invalid pass signing private key"
        case .signingFailed(let detail):
            return "Pass signing failed: \(detail)"
        case .archiveFailed(let detail):
            return "Failed to create pass archive: \(detail)"
        case .colorConversionFailed:
            return "Failed to convert card color"
        }
    }
}

enum WalletPassGenerator {

    // MARK: - Public

    static func generate(for card: LoyaltyCard) throws -> Data {
        guard card.barcodeType.supportsAppleWallet else {
            throw WalletPassGeneratorError.unsupportedBarcodeType
        }

        let passJSON = try buildPassJSON(for: card)
        let assets = try collectAssets(for: card)
        let manifest = try buildManifest(passJSON: passJSON, assets: assets)
        let signature = try signManifest(manifest)

        return try buildArchive(
            passJSON: passJSON,
            manifest: manifest,
            signature: signature,
            assets: assets
        )
    }

    // MARK: - Pass JSON

    static func buildPassJSON(for card: LoyaltyCard) throws -> Data {
        var pass: [String: Any] = [
            "formatVersion": 1,
            "passTypeIdentifier": WalletPassConfiguration.passTypeIdentifier,
            "teamIdentifier": WalletPassConfiguration.teamIdentifier,
            "serialNumber": card.id.uuidString,
            "organizationName": WalletPassConfiguration.organizationName,
            "description": card.name,
        ]

        // Colors
        if let hex = card.color, let color = Color(hex: hex), let rgb = color.toPassRGB() {
            pass["backgroundColor"] = rgb
        }
        if let hex = card.secondaryColor, let color = Color(hex: hex), let rgb = color.toPassRGB() {
            pass["foregroundColor"] = rgb
        } else if let hex = card.color, let color = Color(hex: hex) {
            pass["foregroundColor"] = color.contrastingTextColor().toPassRGB()
        }

        pass["logoText"] = card.storeName

        var storeCard: [String: Any] = [:]

        storeCard["primaryFields"] = [[
            "key": "cardName",
            "label": "",
            "value": card.name,
        ]]

        if !card.cardNumber.isEmpty {
            storeCard["secondaryFields"] = [[
                "key": "cardNumber",
                "label": "NUMBER",
                "value": card.cardNumber,
            ]]
        }

        pass["storeCard"] = storeCard

        // Barcode
        if let format = card.barcodeType.walletFormatString {
            let barcode: [String: Any] = [
                "message": card.barcodeData,
                "format": format,
                "messageEncoding": "iso-8859-1",
            ]
            pass["barcode"] = barcode
            pass["barcodes"] = [barcode]
        }

        // Locations
        if !card.locations.isEmpty {
            pass["locations"] = card.locations.map { location -> [String: Any] in
                [
                    "latitude": location.latitude,
                    "longitude": location.longitude,
                ]
            }
        }

        // Expiration
        if let expirationDate = card.expirationDate {
            let formatter = ISO8601DateFormatter()
            pass["expirationDate"] = formatter.string(from: expirationDate)
        }

        return try JSONSerialization.data(
            withJSONObject: pass,
            options: [.prettyPrinted, .sortedKeys]
        )
    }

    // MARK: - Assets

    static func collectAssets(for card: LoyaltyCard) throws -> [String: Data] {
        var assets: [String: Data] = [:]
        let bundle = Bundle.main

        for asset in WalletPassConfiguration.iconAssets {
            guard let url = bundle.url(forResource: asset.resource, withExtension: "png"),
                  let data = try? Data(contentsOf: url)
            else {
                throw WalletPassGeneratorError.missingResource("\(asset.resource).png")
            }
            assets["\(asset.archiveName).png"] = data
        }

        for asset in WalletPassConfiguration.logoAssets {
            guard let url = bundle.url(forResource: asset.resource, withExtension: "png"),
                  let image = UIImage(contentsOfFile: url.path)
            else {
                throw WalletPassGeneratorError.missingResource("\(asset.resource).png")
            }
            assets["\(asset.archiveName).png"] = renderLogoWithTransparentBackground(image)
        }

        if let imageData = card.cardImage, let sourceImage = UIImage(data: imageData) {
            let stripAssets = renderStripImages(from: sourceImage)
            for (filename, data) in stripAssets {
                assets[filename] = data
            }
        }

        return assets
    }

    /// Strips near-white background pixels from a logo image, making them transparent.
    private static func renderLogoWithTransparentBackground(_ source: UIImage) -> Data {
        guard let cgImage = source.cgImage,
              let masked = cgImage.copy(maskingColorComponents: [220, 255, 220, 255, 220, 255])
        else {
            return source.pngData() ?? Data()
        }
        let maskedImage = UIImage(cgImage: masked, scale: source.scale, orientation: source.imageOrientation)
        let renderer = UIGraphicsImageRenderer(size: source.size)
        return renderer.pngData { _ in
            maskedImage.draw(at: .zero)
        }
    }

    /// Renders strip images at @1x, @2x, and @3x from a source image.
    private static func renderStripImages(from source: UIImage) -> [String: Data] {
        let baseWidth = WalletPassConfiguration.stripWidth
        let baseHeight = WalletPassConfiguration.stripHeight
        let scales: [(suffix: String, scale: CGFloat)] = [
            ("strip.png", 1),
            ("strip@2x.png", 2),
            ("strip@3x.png", 3),
        ]

        var result: [String: Data] = [:]
        for (filename, scale) in scales {
            let size = CGSize(width: baseWidth * scale, height: baseHeight * scale)
            let renderer = UIGraphicsImageRenderer(size: size)
            let rendered = renderer.pngData { context in
                source.draw(in: CGRect(origin: .zero, size: size))
            }
            result[filename] = rendered
        }
        return result
    }

    // MARK: - Manifest

    static func buildManifest(passJSON: Data, assets: [String: Data]) throws -> Data {
        var manifest: [String: String] = [:]

        manifest["pass.json"] = sha1Hash(passJSON)
        for (filename, data) in assets {
            manifest[filename] = sha1Hash(data)
        }

        return try JSONSerialization.data(
            withJSONObject: manifest,
            options: [.prettyPrinted, .sortedKeys]
        )
    }

    static func sha1Hash(_ data: Data) -> String {
        let digest = Insecure.SHA1.hash(data: data)
        return digest.map { String(format: "%02x", $0) }.joined()
    }

    // MARK: - Signing

    static func signManifest(_ manifestData: Data) throws -> Data {
        let bundle = Bundle.main

        guard let certURL = bundle.url(
            forResource: WalletPassConfiguration.certificateResource,
            withExtension: "pem"
        ), let certPEM = try? String(contentsOf: certURL, encoding: .utf8) else {
            throw WalletPassGeneratorError.missingResource("pass-certificate.pem")
        }

        guard let keyURL = bundle.url(
            forResource: WalletPassConfiguration.privateKeyResource,
            withExtension: "pem"
        ), let keyPEM = try? String(contentsOf: keyURL, encoding: .utf8) else {
            throw WalletPassGeneratorError.missingResource("pass-key.pem")
        }

        guard let wwdrURL = bundle.url(
            forResource: WalletPassConfiguration.wwdrCertificateResource,
            withExtension: "pem"
        ), let wwdrPEM = try? String(contentsOf: wwdrURL, encoding: .utf8) else {
            throw WalletPassGeneratorError.missingResource("wwdr.pem")
        }

        let passCert: Certificate
        do {
            passCert = try Certificate(pemEncoded: certPEM)
        } catch {
            throw WalletPassGeneratorError.invalidCertificate
        }

        let wwdrCert: Certificate
        do {
            wwdrCert = try Certificate(pemEncoded: wwdrPEM)
        } catch {
            throw WalletPassGeneratorError.invalidCertificate
        }

        let privateKey: Certificate.PrivateKey
        do {
            let rsaKey = try _RSA.Signing.PrivateKey(pemRepresentation: keyPEM)
            privateKey = Certificate.PrivateKey(rsaKey)
        } catch {
            throw WalletPassGeneratorError.invalidPrivateKey
        }

        do {
            let signature = try CMS.sign(
                manifestData,
                signatureAlgorithm: .sha256WithRSAEncryption,
                additionalIntermediateCertificates: [wwdrCert],
                certificate: passCert,
                privateKey: privateKey,
                signingTime: Date()
            )
            return Data(signature)
        } catch {
            throw WalletPassGeneratorError.signingFailed(error.localizedDescription)
        }
    }

    // MARK: - Archive

    static func buildArchive(
        passJSON: Data,
        manifest: Data,
        signature: Data,
        assets: [String: Data]
    ) throws -> Data {
        let archive: Archive
        do {
            archive = try Archive(accessMode: .create)
        } catch {
            throw WalletPassGeneratorError.archiveFailed("Could not create archive: \(error.localizedDescription)")
        }

        do {
            try addArchiveEntry(archive: archive, path: "pass.json", data: passJSON)
            try addArchiveEntry(archive: archive, path: "manifest.json", data: manifest)
            try addArchiveEntry(archive: archive, path: "signature", data: signature)

            for (filename, data) in assets {
                try addArchiveEntry(archive: archive, path: filename, data: data)
            }
        } catch let error as WalletPassGeneratorError {
            throw error
        } catch {
            throw WalletPassGeneratorError.archiveFailed(error.localizedDescription)
        }

        return archive.data ?? Data()
    }

    private static func addArchiveEntry(archive: Archive, path: String, data: Data) throws {
        let size = Int64(data.count)
        try archive.addEntry(with: path, type: .file, uncompressedSize: size) { position, chunkSize in
            let start = Int(position)
            let end = start + chunkSize
            return data.subdata(in: start..<end)
        }
    }
}

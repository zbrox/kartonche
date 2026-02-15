//
//  WalletPassGeneratorTests.swift
//  kartoncheTests
//
//  Created on 2026-02-10.
//

import Testing
import Foundation
import ZIPFoundation
@testable import kartonche

@MainActor
struct WalletPassGeneratorTests {

    // MARK: - pass.json structure

    private func makeCard(
        name: String = "Test Card",
        storeName: String? = "Test Store",
        cardNumber: String = "1234567890",
        barcodeType: BarcodeType = .qr,
        barcodeData: String = "test-barcode-data",
        color: String? = "#FF0000",
        secondaryColor: String? = "#FFFFFF",
        expirationDate: Date? = nil,
        cardholderName: String? = nil
    ) -> LoyaltyCard {
        let card = LoyaltyCard(
            name: name,
            storeName: storeName,
            cardNumber: cardNumber,
            barcodeType: barcodeType,
            barcodeData: barcodeData,
            color: color,
            secondaryColor: secondaryColor,
            expirationDate: expirationDate
        )
        card.cardholderName = cardholderName
        return card
    }

    @Test func passJSONContainsRequiredTopLevelFields() throws {
        let card = makeCard()
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["formatVersion"] as? Int == 1)
        #expect(json["passTypeIdentifier"] as? String == WalletPassConfiguration.passTypeIdentifier)
        #expect(json["teamIdentifier"] as? String == WalletPassConfiguration.teamIdentifier)
        #expect(json["serialNumber"] as? String == card.id.uuidString)
        #expect(json["organizationName"] as? String == WalletPassConfiguration.organizationName)
        #expect(json["description"] as? String == "Test Card")
    }

    @Test func passJSONContainsStoreCardFields() throws {
        let card = makeCard()
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["logoText"] as? String == "Test Store")

        let storeCard = json["storeCard"] as! [String: Any]
        #expect(storeCard["headerFields"] == nil)

        let primaryFields = storeCard["primaryFields"] as! [[String: Any]]
        #expect(primaryFields[0]["value"] as? String == "Test Card")

        let secondaryFields = storeCard["secondaryFields"] as! [[String: Any]]
        #expect(secondaryFields[0]["value"] as? String == "1234567890")
        #expect(secondaryFields[0]["label"] as? String == "NUMBER")
    }

    @Test func passJSONOmitsLogoTextWhenStoreNameNil() throws {
        let card = makeCard(storeName: nil)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["logoText"] == nil)
    }

    @Test func passJSONOmitsLogoTextWhenStoreNameEmpty() throws {
        let card = makeCard(storeName: "")
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["logoText"] == nil)
    }

    @Test func passJSONOmitsSecondaryFieldsWhenCardNumberEmpty() throws {
        let card = makeCard(cardNumber: "")
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let storeCard = json["storeCard"] as! [String: Any]

        #expect(storeCard["secondaryFields"] == nil)
    }

    @Test func passJSONContainsBarcodeForQR() throws {
        let card = makeCard(barcodeType: .qr)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        let barcode = json["barcode"] as! [String: Any]
        #expect(barcode["format"] as? String == "PKBarcodeFormatQR")
        #expect(barcode["message"] as? String == "test-barcode-data")
        #expect(barcode["messageEncoding"] as? String == "iso-8859-1")

        let barcodes = json["barcodes"] as! [[String: Any]]
        #expect(barcodes.count == 1)
        #expect(barcodes[0]["format"] as? String == "PKBarcodeFormatQR")
    }

    @Test func passJSONContainsBarcodeForCode128() throws {
        let card = makeCard(barcodeType: .code128)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let barcode = json["barcode"] as! [String: Any]
        #expect(barcode["format"] as? String == "PKBarcodeFormatCode128")
    }

    @Test func passJSONContainsBarcodeForPDF417() throws {
        let card = makeCard(barcodeType: .pdf417)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let barcode = json["barcode"] as! [String: Any]
        #expect(barcode["format"] as? String == "PKBarcodeFormatPDF417")
    }

    @Test func passJSONContainsBarcodeForAztec() throws {
        let card = makeCard(barcodeType: .aztec)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let barcode = json["barcode"] as! [String: Any]
        #expect(barcode["format"] as? String == "PKBarcodeFormatAztec")
    }

    @Test func passJSONContainsColors() throws {
        let card = makeCard(color: "#FF0000", secondaryColor: "#00FF00")
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["backgroundColor"] as? String == "rgb(255,0,0)")
        #expect(json["foregroundColor"] as? String == "rgb(0,255,0)")
    }

    @Test func passJSONUsesContrastingColorWhenNoSecondaryColor() throws {
        let card = makeCard(color: "#000000", secondaryColor: nil)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["backgroundColor"] as? String == "rgb(0,0,0)")
        // Black background → white foreground
        #expect(json["foregroundColor"] as? String == "rgb(255,255,255)")
    }

    @Test func passJSONContainsExpirationDate() throws {
        let date = ISO8601DateFormatter().date(from: "2027-01-15T00:00:00Z")!
        let card = makeCard(expirationDate: date)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["expirationDate"] as? String == "2027-01-15T00:00:00Z")
    }

    @Test func passJSONOmitsExpirationDateWhenNil() throws {
        let card = makeCard(expirationDate: nil)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["expirationDate"] == nil)
    }

    @Test func passJSONContainsAuxiliaryFieldsWhenCardholderNameSet() throws {
        let card = makeCard(cardholderName: "John Doe")
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let storeCard = json["storeCard"] as! [String: Any]

        let auxiliaryFields = storeCard["auxiliaryFields"] as! [[String: Any]]
        #expect(auxiliaryFields.count == 1)
        #expect(auxiliaryFields[0]["key"] as? String == "cardholderName")
        #expect(auxiliaryFields[0]["label"] as? String == "CARDHOLDER")
        #expect(auxiliaryFields[0]["value"] as? String == "John Doe")
    }

    @Test func passJSONOmitsAuxiliaryFieldsWhenCardholderNameNil() throws {
        let card = makeCard(cardholderName: nil)
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let storeCard = json["storeCard"] as! [String: Any]

        #expect(storeCard["auxiliaryFields"] == nil)
    }

    @Test func passJSONOmitsAuxiliaryFieldsWhenCardholderNameEmpty() throws {
        let card = makeCard(cardholderName: "")
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let storeCard = json["storeCard"] as! [String: Any]

        #expect(storeCard["auxiliaryFields"] == nil)
    }

    @Test func passJSONOmitsLocationsWhenEmpty() throws {
        let card = makeCard()
        let data = try WalletPassGenerator.buildPassJSON(for: card)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        #expect(json["locations"] == nil)
    }

    // MARK: - SHA1 hashing

    @Test func sha1HashProducesCorrectOutput() {
        let data = "hello world".data(using: .utf8)!
        let hash = WalletPassGenerator.sha1Hash(data)
        // Known SHA1 of "hello world"
        #expect(hash == "2aae6c35c94fcfb415dbe95f408b9ce91ee846ed")
    }

    // MARK: - Manifest

    @Test func manifestContainsHashesForAllFiles() throws {
        let passJSON = "test-pass".data(using: .utf8)!
        let assets = [
            "icon.png": "icon-data".data(using: .utf8)!,
            "logo.png": "logo-data".data(using: .utf8)!,
        ]

        let manifestData = try WalletPassGenerator.buildManifest(passJSON: passJSON, assets: assets)
        let manifest = try JSONSerialization.jsonObject(with: manifestData) as! [String: String]

        #expect(manifest.count == 3)
        #expect(manifest["pass.json"] == WalletPassGenerator.sha1Hash(passJSON))
        #expect(manifest["icon.png"] == WalletPassGenerator.sha1Hash(assets["icon.png"]!))
        #expect(manifest["logo.png"] == WalletPassGenerator.sha1Hash(assets["logo.png"]!))
    }

    // MARK: - Archive

    @Test func archiveContainsExpectedEntries() throws {
        let passJSON = "{\"test\":true}".data(using: .utf8)!
        let manifest = "{\"pass.json\":\"abc\"}".data(using: .utf8)!
        let signature = "fake-signature".data(using: .utf8)!
        let assets = [
            "icon.png": "icon-data".data(using: .utf8)!,
        ]

        let archiveData = try WalletPassGenerator.buildArchive(
            passJSON: passJSON,
            manifest: manifest,
            signature: signature,
            assets: assets
        )

        #expect(!archiveData.isEmpty)

        // Verify ZIP contains expected entries by reading it back
        guard let archive = Archive(data: archiveData, accessMode: .read) else {
            Issue.record("Could not read generated archive")
            return
        }

        let entryNames = Set(archive.map(\.path))
        #expect(entryNames.contains("pass.json"))
        #expect(entryNames.contains("manifest.json"))
        #expect(entryNames.contains("signature"))
        #expect(entryNames.contains("icon.png"))
    }

    @Test func archivePassJSONContentMatches() throws {
        let passJSON = "{\"formatVersion\":1}".data(using: .utf8)!
        let manifest = "{}".data(using: .utf8)!
        let signature = Data([0x00])
        let assets: [String: Data] = [:]

        let archiveData = try WalletPassGenerator.buildArchive(
            passJSON: passJSON,
            manifest: manifest,
            signature: signature,
            assets: assets
        )

        guard let archive = Archive(data: archiveData, accessMode: .read) else {
            Issue.record("Could not read generated archive")
            return
        }

        guard let entry = archive["pass.json"] else {
            Issue.record("pass.json not found in archive")
            return
        }

        var extractedData = Data()
        _ = try archive.extract(entry) { chunk in
            extractedData.append(chunk)
        }
        #expect(extractedData == passJSON)
    }
}

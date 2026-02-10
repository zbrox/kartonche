//
//  CardExportDTO.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import Foundation

/// Data Transfer Object for exporting/importing loyalty cards
/// Uses .kartonche file format (JSON-based)
struct CardExportContainer: Codable {
    /// File format version for compatibility
    let version: String
    
    /// Export timestamp
    let exportDate: Date
    
    /// Cards to export
    let cards: [CardExportDTO]
    
    /// Current file format version
    static let currentVersion = "1.0"
    
    init(cards: [CardExportDTO], exportDate: Date = Date()) {
        self.version = Self.currentVersion
        self.exportDate = exportDate
        self.cards = cards
    }
}

/// Codable representation of a LoyaltyCard for export/import
struct CardExportDTO: Codable, Identifiable {
    let id: UUID
    let name: String
    let storeName: String
    let cardNumber: String
    let barcodeType: String
    let barcodeData: String
    let color: String?
    let secondaryColor: String?
    let notes: String?
    let isFavorite: Bool
    let createdDate: Date
    let lastUsedDate: Date?
    let expirationDate: Date?
    
    /// Base64-encoded image data (optional, can be large)
    let cardImage: String?
    
    /// Locations associated with this card
    let locations: [LocationExportDTO]
    
    /// Validate that this DTO can be safely converted to a LoyaltyCard
    func validate() throws {
        // Check required fields are not empty
        guard !name.isEmpty else {
            throw CardImportError.invalidData("Card name is empty")
        }
        
        guard !storeName.isEmpty else {
            throw CardImportError.invalidData("Store name is empty")
        }
        
        guard !barcodeData.isEmpty else {
            throw CardImportError.invalidData("Barcode data is empty")
        }
        
        // Validate barcode type
        guard BarcodeType(rawValue: barcodeType) != nil else {
            throw CardImportError.invalidData("Unknown barcode type: \(barcodeType)")
        }
        
        // Validate base64 image if present
        if let imageBase64 = cardImage, !imageBase64.isEmpty {
            guard Data(base64Encoded: imageBase64) != nil else {
                throw CardImportError.invalidData("Invalid card image data")
            }
        }
    }
}

/// Codable representation of a CardLocation for export/import
struct LocationExportDTO: Codable {
    let id: UUID
    let name: String
    let address: String
    let latitude: Double
    let longitude: Double
    let radius: Double
}

// MARK: - SwiftData Integration (Main App Only)
// These extensions depend on SwiftData models and are excluded from extensions
// The MAIN_APP flag is set in the main app target's build settings

#if MAIN_APP
extension CardExportDTO {
    /// Convert from LoyaltyCard (SwiftData) to CardExportDTO (Codable)
    init(from card: LoyaltyCard) {
        self.id = card.id
        self.name = card.name
        self.storeName = card.storeName
        self.cardNumber = card.cardNumber
        self.barcodeType = card.barcodeType.rawValue
        self.barcodeData = card.barcodeData
        self.color = card.color
        self.secondaryColor = card.secondaryColor
        self.notes = card.notes
        self.isFavorite = card.isFavorite
        self.createdDate = card.createdDate
        self.lastUsedDate = card.lastUsedDate
        self.expirationDate = card.expirationDate
        
        // Convert image Data to base64 string for JSON serialization
        if let imageData = card.cardImage {
            self.cardImage = imageData.base64EncodedString()
        } else {
            self.cardImage = nil
        }
        
        // Convert locations
        self.locations = card.locations.map { LocationExportDTO(from: $0) }
    }
}

extension LocationExportDTO {
    init(from location: CardLocation) {
        self.id = location.id
        self.name = location.name
        self.address = location.address
        self.latitude = location.latitude
        self.longitude = location.longitude
        self.radius = location.radius
    }
}
#endif

/// Errors that can occur during import
enum CardImportError: LocalizedError {
    case invalidFileFormat
    case unsupportedVersion(String)
    case invalidData(String)
    case decodingFailed(Error)
    case fileNotFound
    
    var errorDescription: String? {
        switch self {
        case .invalidFileFormat:
            return String(localized: "Invalid file format. Expected .kartonche file.")
        case .unsupportedVersion(let version):
            return String(localized: "Unsupported file version: \(version)")
        case .invalidData(let details):
            return String(localized: "Invalid card data: \(details)")
        case .decodingFailed(let error):
            return String(localized: "Failed to read file: \(error.localizedDescription)")
        case .fileNotFound:
            return String(localized: "File not found")
        }
    }
}

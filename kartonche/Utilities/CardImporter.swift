//
//  CardImporter.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import Foundation
import SwiftData
import UIKit

/// Imports loyalty cards from .kartonche files
struct CardImporter {
    
    // MARK: - Duplicate Detection
    
    /// Represents a detected duplicate card
    struct DuplicateInfo {
        let importedCard: CardExportDTO
        let existingCard: LoyaltyCard
        
        /// Returns true if cards are identical (same content, not just same identity)
        var areIdentical: Bool {
            return existingCard.name == importedCard.name &&
                   (existingCard.storeName ?? "") == (importedCard.storeName ?? "") &&
                   existingCard.cardNumber == importedCard.cardNumber
        }
    }
    
    enum ImportStrategy {
        case skipDuplicates      // Don't import duplicates
        case replaceDuplicates   // Replace existing cards with imported versions
        case keepBoth           // Import as new cards even if duplicates exist
    }
    
    // MARK: - Import Errors
    
    enum ImportError: LocalizedError {
        case invalidJSON
        case unsupportedVersion(String)
        case validationFailed(CardImportError)
        case noCards
        case duplicateIDsInImport
        
        var errorDescription: String? {
            switch self {
            case .invalidJSON:
                return "Invalid file format"
            case .unsupportedVersion(let version):
                return "Unsupported file version: \(version)"
            case .validationFailed(let error):
                return "Card validation failed: \(error.localizedDescription)"
            case .noCards:
                return "No cards found in file"
            case .duplicateIDsInImport:
                return "File contains duplicate card IDs"
            }
        }
    }
    
    // MARK: - Import from Data
    
    /// Parses JSON data and returns a validated CardExportContainer
    static func importFromData(_ data: Data) throws -> CardExportContainer {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let container: CardExportContainer
        do {
            container = try decoder.decode(CardExportContainer.self, from: data)
        } catch {
            throw ImportError.invalidJSON
        }
        
        // Validate version
        guard container.version == "1.0" else {
            throw ImportError.unsupportedVersion(container.version)
        }
        
        // Ensure we have cards
        guard !container.cards.isEmpty else {
            throw ImportError.noCards
        }
        
        // Check for duplicate IDs within import file
        let ids = container.cards.map { $0.id }
        let uniqueIds = Set(ids)
        guard ids.count == uniqueIds.count else {
            throw ImportError.duplicateIDsInImport
        }
        
        // Validate each card
        for card in container.cards {
            do {
                try card.validate()
            } catch let error as CardImportError {
                throw ImportError.validationFailed(error)
            }
        }
        
        return container
    }
    
    // MARK: - Duplicate Detection
    
    /// Detects duplicate cards by comparing cardNumber + storeName, or just storeName if cardNumber is nil
    static func detectDuplicates(
        _ importedCards: [CardExportDTO],
        existingCards: [LoyaltyCard]
    ) -> [DuplicateInfo] {
        var duplicates: [DuplicateInfo] = []
        
        for importedCard in importedCards {
            for existingCard in existingCards {
                // Compare by storeName + cardNumber (treat nil same as empty)
                let isDuplicate = (importedCard.storeName ?? "") == (existingCard.storeName ?? "") &&
                                  importedCard.cardNumber == existingCard.cardNumber
                
                if isDuplicate {
                    duplicates.append(DuplicateInfo(
                        importedCard: importedCard,
                        existingCard: existingCard
                    ))
                    break // Only count first match per imported card
                }
            }
        }
        
        return duplicates
    }
    
    // MARK: - Import Cards into SwiftData
    
    /// Imports cards into SwiftData model context with specified strategy
    @MainActor
    static func importCards(
        from container: CardExportContainer,
        into modelContext: ModelContext,
        strategy: ImportStrategy = .skipDuplicates
    ) throws -> ImportResult {
        let existingCards = try modelContext.fetch(FetchDescriptor<LoyaltyCard>())
        let duplicates = detectDuplicates(container.cards, existingCards: existingCards)
        
        var importedCount = 0
        var skippedCount = 0
        var replacedCount = 0
        
        for cardDTO in container.cards {
            let duplicate = duplicates.first { $0.importedCard.id == cardDTO.id }
            
            switch strategy {
            case .skipDuplicates:
                if duplicate != nil {
                    skippedCount += 1
                    continue
                }
                try createCard(from: cardDTO, in: modelContext)
                importedCount += 1
                
            case .replaceDuplicates:
                if let duplicate = duplicate {
                    // Delete existing card
                    modelContext.delete(duplicate.existingCard)
                    replacedCount += 1
                }
                try createCard(from: cardDTO, in: modelContext)
                importedCount += 1
                
            case .keepBoth:
                try createCard(from: cardDTO, in: modelContext)
                importedCount += 1
            }
        }
        
        try modelContext.save()
        
        return ImportResult(
            importedCount: importedCount,
            skippedCount: skippedCount,
            replacedCount: replacedCount,
            duplicatesDetected: duplicates.count
        )
    }
    
    // MARK: - CardExportDTO to LoyaltyCard Conversion
    
    /// Creates a LoyaltyCard from CardExportDTO
    @MainActor
    private static func createCard(from dto: CardExportDTO, in modelContext: ModelContext) throws {
        let card = LoyaltyCard(
            name: dto.name,
            storeName: dto.storeName,
            cardNumber: dto.cardNumber,
            barcodeType: dto.barcodeType,
            barcodeData: dto.barcodeData,
            color: dto.color,
            secondaryColor: dto.secondaryColor
        )
        
        // Set optional properties
        card.notes = dto.notes
        card.cardholderName = dto.cardholderName
        card.isFavorite = dto.isFavorite
        card.createdDate = dto.createdDate
        card.lastUsedDate = dto.lastUsedDate
        card.expirationDate = dto.expirationDate
        
        // Decode and set card image if present
        if let imageBase64 = dto.cardImage,
           let imageData = Data(base64Encoded: imageBase64),
           let image = UIImage(data: imageData),
           let pngData = image.pngData() {
            card.cardImage = pngData
        }
        
        modelContext.insert(card)
        
        // Create locations
        for locationDTO in dto.locations {
            let location = CardLocation(
                name: locationDTO.name,
                address: locationDTO.address,
                latitude: locationDTO.latitude,
                longitude: locationDTO.longitude,
                radius: locationDTO.radius
            )
            card.locations.append(location)
            modelContext.insert(location)
        }
    }
    
    // MARK: - Import Result
    
    struct ImportResult {
        let importedCount: Int
        let skippedCount: Int
        let replacedCount: Int
        let duplicatesDetected: Int
        
        var totalProcessed: Int {
            importedCount + skippedCount
        }
        
        var hasChanges: Bool {
            importedCount > 0 || replacedCount > 0
        }
    }
}

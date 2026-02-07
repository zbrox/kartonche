//
//  CardExporter.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import Foundation

/// Utility for exporting loyalty cards to .kartonche files
enum CardExporter {
    
    /// Export a single card to .kartonche file data
    /// - Parameter card: The card to export
    /// - Returns: JSON data ready for sharing
    /// - Throws: Encoding errors
    static func exportCard(_ card: LoyaltyCard) throws -> Data {
        let dto = CardExportDTO(from: card)
        let container = CardExportContainer(cards: [dto])
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(container)
    }
    
    /// Export multiple cards to .kartonche file data
    /// - Parameter cards: Array of cards to export
    /// - Returns: JSON data ready for sharing
    /// - Throws: Encoding errors
    static func exportCards(_ cards: [LoyaltyCard]) throws -> Data {
        let dtos = cards.map { CardExportDTO(from: $0) }
        let container = CardExportContainer(cards: dtos)
        
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        
        return try encoder.encode(container)
    }
    
    /// Create a temporary file URL for sharing
    /// - Parameters:
    ///   - data: The encoded card data
    ///   - fileName: Base name for the file (default: "cards")
    /// - Returns: URL to temporary file
    /// - Throws: File writing errors
    static func createTemporaryFile(from data: Data, fileName: String = "cards") throws -> URL {
        let tempDir = FileManager.default.temporaryDirectory
        let fileURL = tempDir.appendingPathComponent("\(fileName).kartonche")
        
        try data.write(to: fileURL, options: .atomic)
        
        return fileURL
    }
    
    /// Generate a default filename for export
    /// - Parameters:
    ///   - cardCount: Number of cards being exported
    ///   - cardName: Name of single card (if exporting one)
    /// - Returns: Sanitized filename without extension
    static func generateFileName(cardCount: Int, cardName: String? = nil) -> String {
        if cardCount == 1, let name = cardName {
            // Single card: use card name
            let sanitized = name
                .replacingOccurrences(of: "[^a-zA-Z0-9а-яА-Я ]", with: "", options: .regularExpression)
                .trimmingCharacters(in: .whitespaces)
                .replacingOccurrences(of: " ", with: "_")
            
            return sanitized.isEmpty ? "card" : sanitized
        } else {
            // Multiple cards: use timestamp
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd"
            let dateString = formatter.string(from: Date())
            return "kartonche_backup_\(dateString)"
        }
    }
    
    /// Calculate the approximate size of export data
    /// - Parameter cards: Cards to estimate size for
    /// - Returns: Estimated size in bytes
    static func estimateSize(for cards: [LoyaltyCard]) -> Int {
        // Rough estimation:
        // - Base card data: ~500 bytes per card
        // - Each location: ~200 bytes
        // - Images can be large: use actual size if present
        
        var totalSize = 1000 // Container overhead
        
        for card in cards {
            totalSize += 500 // Base card data
            totalSize += card.locations.count * 200 // Locations
            
            if let imageData = card.cardImage {
                totalSize += imageData.count // Actual image size
            }
        }
        
        return totalSize
    }
    
    /// Format byte size for display
    /// - Parameter bytes: Size in bytes
    /// - Returns: Human-readable string (e.g., "2.5 MB")
    static func formatByteSize(_ bytes: Int) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useKB, .useMB]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

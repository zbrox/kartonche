//
//  LoyaltyCard.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import Foundation
import SwiftData

@Model
final class LoyaltyCard {
    var id: UUID
    var name: String
    var storeName: String
    var cardNumber: String
    var barcodeType: BarcodeType
    var barcodeData: String
    var color: String?
    var secondaryColor: String?
    var notes: String?
    var isFavorite: Bool
    var createdDate: Date
    var lastUsedDate: Date?
    var expirationDate: Date?
    
    @Attribute(.externalStorage)
    var cardImage: Data?
    
    init(
        id: UUID = UUID(),
        name: String,
        storeName: String,
        cardNumber: String,
        barcodeType: BarcodeType,
        barcodeData: String,
        color: String? = nil,
        secondaryColor: String? = nil,
        notes: String? = nil,
        isFavorite: Bool = false,
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        expirationDate: Date? = nil,
        cardImage: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.storeName = storeName
        self.cardNumber = cardNumber
        self.barcodeType = barcodeType
        self.barcodeData = barcodeData
        self.color = color
        self.secondaryColor = secondaryColor
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.expirationDate = expirationDate
        self.cardImage = cardImage
    }
    
    /// Returns true if the card has expired
    var isExpired: Bool {
        guard let expirationDate = expirationDate else { return false }
        return expirationDate < Date()
    }
    
    /// Returns true if the card expires within the next 30 days
    var isExpiringSoon: Bool {
        guard let expirationDate = expirationDate else { return false }
        let thirtyDaysFromNow = Calendar.current.date(byAdding: .day, value: 30, to: Date()) ?? Date()
        return expirationDate > Date() && expirationDate <= thirtyDaysFromNow
    }
}

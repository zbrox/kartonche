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
    var notes: String?
    var isFavorite: Bool
    var createdDate: Date
    var lastUsedDate: Date?
    
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
        notes: String? = nil,
        isFavorite: Bool = false,
        createdDate: Date = Date(),
        lastUsedDate: Date? = nil,
        cardImage: Data? = nil
    ) {
        self.id = id
        self.name = name
        self.storeName = storeName
        self.cardNumber = cardNumber
        self.barcodeType = barcodeType
        self.barcodeData = barcodeData
        self.color = color
        self.notes = notes
        self.isFavorite = isFavorite
        self.createdDate = createdDate
        self.lastUsedDate = lastUsedDate
        self.cardImage = cardImage
    }
}

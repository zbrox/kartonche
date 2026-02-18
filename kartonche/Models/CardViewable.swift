//
//  CardViewable.swift
//  kartonche
//
//  Created on 2026-02-10.
//

import Foundation

/// Protocol for types that can be displayed as a card in CardView
protocol CardViewable {
    var name: String { get }
    var storeName: String? { get }
    var cardNumber: String? { get }
    var barcodeType: BarcodeType { get }
    var barcodeData: String { get }
    var color: String? { get }
    var secondaryColor: String? { get }
    var notes: String? { get }
    var cardholderName: String? { get }
}

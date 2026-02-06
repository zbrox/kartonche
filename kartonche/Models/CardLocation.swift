//
//  CardLocation.swift
//  kartonche
//
//  Created on 2026-02-06.
//

import Foundation
import SwiftData
import CoreLocation

@Model
final class CardLocation {
    var id: UUID
    var name: String
    var address: String
    var latitude: Double
    var longitude: Double
    var radius: Double // in meters
    
    // Relationship to card (inverse of LoyaltyCard.locations)
    var card: LoyaltyCard?
    
    init(
        id: UUID = UUID(),
        name: String,
        address: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 500.0
    ) {
        self.id = id
        self.name = name
        self.address = address
        self.latitude = latitude
        self.longitude = longitude
        self.radius = radius
    }
    
    /// Returns a CLLocationCoordinate2D for this location
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    /// Returns the distance in meters from a given coordinate
    func distance(from coordinate: CLLocationCoordinate2D) -> Double {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        let otherLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        return location.distance(from: otherLocation)
    }
    
    /// Returns true if the given coordinate is within this location's radius
    func contains(_ coordinate: CLLocationCoordinate2D) -> Bool {
        return distance(from: coordinate) <= radius
    }
}

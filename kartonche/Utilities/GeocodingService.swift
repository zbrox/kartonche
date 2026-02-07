//
//  GeocodingService.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import Foundation
import CoreLocation

/// Service for reverse geocoding coordinates to addresses
enum GeocodingService {
    /// Reverse geocode a location to get a human-readable address
    /// - Parameter location: The location to reverse geocode
    /// - Returns: A tuple containing a suggested name and full address
    /// - Throws: GeocodingError if the operation fails
    static func reverseGeocode(location: CLLocation) async throws -> (name: String, address: String) {
        let geocoder = CLGeocoder()
        let placemarks = try await geocoder.reverseGeocodeLocation(location)
        
        guard let placemark = placemarks.first else {
            throw GeocodingError.noResults
        }
        
        // Generate name from nearby POI or area
        let name = placemark.name ?? placemark.locality ?? String(localized: "Current Location")
        
        // Generate full address
        var addressComponents: [String] = []
        if let name = placemark.name { addressComponents.append(name) }
        if let street = placemark.thoroughfare { addressComponents.append(street) }
        if let city = placemark.locality { addressComponents.append(city) }
        
        let address = addressComponents.isEmpty 
            ? String(localized: "Unknown Address")
            : addressComponents.joined(separator: ", ")
        
        return (name: name, address: address)
    }
}

/// Errors that can occur during geocoding operations
enum GeocodingError: LocalizedError {
    case noResults
    case locationUnavailable
    
    var errorDescription: String? {
        switch self {
        case .noResults:
            return String(localized: "Unable to determine address for this location")
        case .locationUnavailable:
            return String(localized: "Location not available")
        }
    }
}

//
//  GeocodingService.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import Foundation
import CoreLocation
@preconcurrency import MapKit

/// Service for reverse geocoding coordinates to addresses
enum GeocodingService {
    /// Reverse geocode a location to get map item with place information
    /// - Parameter location: The location to reverse geocode
    /// - Returns: An MKMapItem containing place information, name, and address
    /// - Throws: GeocodingError if the operation fails
    static func reverseGeocode(location: CLLocation) async throws -> MKMapItem {
        // Use MapKit's MKReverseGeocodingRequest (iOS 26+)
        guard let request = MKReverseGeocodingRequest(location: location) else {
            throw GeocodingError.noResults
        }
        
        // Get map items using async property accessor
        let mapItems = try await request.mapItems
        
        // Extract first result
        guard let mapItem = mapItems.first else {
            throw GeocodingError.noResults
        }
        
        return mapItem
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

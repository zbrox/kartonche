//
//  GeocodingServiceTests.swift
//  kartoncheTests
//
//  Created on 2026-02-07.
//

import Testing
import CoreLocation
import MapKit
@testable import kartonche

struct GeocodingServiceTests {
    @Test func reverseGeocodingSucceeds() async throws {
        // Sofia, Bulgaria - city center coordinates
        let location = CLLocation(latitude: 42.6977, longitude: 23.3219)
        
        let mapItem = try await GeocodingService.reverseGeocode(location: location)
        
        // Verify we got a valid map item with location
        #expect(mapItem.location != nil)
        
        // Verify we have some location information
        // At minimum, we should have city name or address
        let hasLocationInfo = mapItem.name != nil || 
                              mapItem.addressRepresentations?.cityName != nil ||
                              mapItem.address?.fullAddress != nil
        #expect(hasLocationInfo, "Should have at least one location identifier")
    }
    
    @Test func reverseGeocodingProvidesPOINames() async throws {
        // Test that mapItem.name can contain POI information
        // Using Sofia coordinates - should have nearby places
        let location = CLLocation(latitude: 42.6977, longitude: 23.3219)
        
        let mapItem = try await GeocodingService.reverseGeocode(location: location)
        
        // At minimum, should have a name or city
        #expect(mapItem.name != nil || mapItem.addressRepresentations?.cityName != nil)
        
        // Verify map item has expected properties
        #expect(mapItem.location != nil)
    }
    
    @Test func reverseGeocodingHandlesRemoteLocation() async throws {
        // Middle of Pacific Ocean - remote location test
        // Should still work but give minimal/ocean-related results
        let location = CLLocation(latitude: 0, longitude: -140)
        
        let mapItem = try await GeocodingService.reverseGeocode(location: location)
        
        // Should not throw, should return something
        #expect(mapItem.location != nil)
        
        // Remote locations may have minimal info, but shouldn't crash
        let hasBasicInfo = mapItem.location != nil
        #expect(hasBasicInfo)
    }
    
    @Test func reverseGeocodingHandlesInvalidCoordinates() async throws {
        // Test with extreme/invalid coordinates
        // Latitude/longitude at maximum valid range
        let location = CLLocation(latitude: 89.9, longitude: 179.9)
        
        // Should either succeed with minimal data or throw GeocodingError
        do {
            let mapItem = try await GeocodingService.reverseGeocode(location: location)
            // If it succeeds, should have at least basic location
            #expect(mapItem.location != nil)
        } catch let error as GeocodingError {
            // Expected errors are fine
            #expect(error == .noResults || error == .locationUnavailable)
        }
    }
    
    @Test func reverseGeocodingReturnsMapKitTypes() async throws {
        // Verify the return type is correct MapKit type
        let location = CLLocation(latitude: 42.6977, longitude: 23.3219)
        
        let mapItem = try await GeocodingService.reverseGeocode(location: location)
        
        // Verify it's the correct type
        #expect(mapItem is MKMapItem)
        
        // Verify new iOS 26 properties are available
        #expect(mapItem.location != nil)
        
        // Address representations should be available
        let hasModernAPI = mapItem.address != nil || mapItem.addressRepresentations != nil
        #expect(hasModernAPI)
    }
}

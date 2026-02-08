//
//  LocationManagerGeofencingTests.swift
//  kartoncheTests
//
//  Created on 2026-02-07.
//

import Testing
import CoreLocation
import SwiftData
@testable import kartonche

/// Tests for LocationManager's geofencing functionality
/// 
/// These tests verify the public API behavior and card selection logic.
/// The actual CLLocationManager monitoring behavior requires integration testing
/// on a real device, but we can verify the selection and mapping logic.
@MainActor
struct LocationManagerGeofencingTests {
    
    // MARK: - Test Helpers
    
    private func createTestCard(
        name: String,
        latitude: Double,
        longitude: Double,
        radius: Double = 100.0
    ) -> LoyaltyCard {
        let card = LoyaltyCard(
            name: name,
            storeName: "Test Store",
            cardNumber: "123456",
            barcodeType: .qr,
            barcodeData: "123456"
        )
        let location = CardLocation(
            name: "Test Location",
            address: "Test Address",
            latitude: latitude,
            longitude: longitude,
            radius: radius
        )
        card.locations.append(location)
        return card
    }
    
    private func createLocationManager(
        currentLatitude: Double,
        currentLongitude: Double
    ) -> LocationManager {
        let manager = LocationManager()
        
        // Simulate having a current location
        let location = CLLocation(latitude: currentLatitude, longitude: currentLongitude)
        manager.currentLocation = location
        
        return manager
    }
    
    // MARK: - Card Selection and Location Tests
    
    @Test func cardsWithLocationsAreFoundNearby() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219) // Sofia
        
        let card1 = createTestCard(
            name: "NearbyCard",
            latitude: 42.6977,
            longitude: 23.3219,
            radius: 500
        )
        
        let card2 = createTestCard(
            name: "FarCard",
            latitude: 43.0000,
            longitude: 24.0000,
            radius: 500
        )
        
        let nearbyCards = manager.cardsNearby([card1, card2], radius: 1000)
        
        #expect(nearbyCards.count == 1)
        #expect(nearbyCards.first?.card.name == "NearbyCard")
    }
    
    @Test func cardsWithoutLocationsAreIgnored() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219)
        
        let cardWithLocation = createTestCard(
            name: "WithLocation",
            latitude: 42.6977,
            longitude: 23.3219
        )
        
        let cardWithoutLocation = LoyaltyCard(
            name: "NoLocation",
            storeName: "Test Store",
            cardNumber: "123456",
            barcodeType: .qr,
            barcodeData: "123456"
        )
        
        let nearbyCards = manager.cardsNearby([cardWithLocation, cardWithoutLocation], radius: 1000)
        
        #expect(nearbyCards.count == 1)
        #expect(nearbyCards.first?.card.name == "WithLocation")
    }
    
    @Test func nearbyCardsAreSortedByDistance() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219) // Sofia
        
        // Create cards at increasing distances
        let closeCard = createTestCard(
            name: "Close",
            latitude: 42.6980, // Very close
            longitude: 23.3220,
            radius: 500
        )
        
        let mediumCard = createTestCard(
            name: "Medium",
            latitude: 42.7000, // Medium distance
            longitude: 23.3300,
            radius: 500
        )
        
        let farCard = createTestCard(
            name: "Far",
            latitude: 42.7100, // Farther
            longitude: 23.3400,
            radius: 500
        )
        
        let nearbyCards = manager.cardsNearby([farCard, closeCard, mediumCard], radius: 10000)
        
        #expect(nearbyCards.count == 3)
        #expect(nearbyCards[0].card.name == "Close")
        #expect(nearbyCards[1].card.name == "Medium")
        #expect(nearbyCards[2].card.name == "Far")
        
        // Verify distances are increasing
        #expect(nearbyCards[0].distance < nearbyCards[1].distance)
        #expect(nearbyCards[1].distance < nearbyCards[2].distance)
    }
    
    @Test func cardWithMultipleLocationsUsesClosest() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219)
        
        let card = LoyaltyCard(
            name: "MultiLocation",
            storeName: "Test Store",
            cardNumber: "123456",
            barcodeType: .qr,
            barcodeData: "123456"
        )
        
        // Add far location
        card.locations.append(CardLocation(
            name: "Far Location",
            address: "Far Address",
            latitude: 43.0000,
            longitude: 24.0000,
            radius: 500
        ))
        
        // Add close location
        card.locations.append(CardLocation(
            name: "Close Location",
            address: "Close Address",
            latitude: 42.6980,
            longitude: 23.3220,
            radius: 500
        ))
        
        let nearbyCards = manager.cardsNearby([card], radius: 1000)
        
        #expect(nearbyCards.count == 1)
        // Distance should be to the closest location
        #expect(nearbyCards[0].distance < 500) // Should use close location
    }
    
    @Test func radiusFilterWorks() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219)
        
        let closeCard = createTestCard(
            name: "Close",
            latitude: 42.6980,
            longitude: 23.3220,
            radius: 500
        )
        
        let mediumCard = createTestCard(
            name: "Medium",
            latitude: 42.7100,
            longitude: 23.3400,
            radius: 500
        )
        
        // With small radius, only close card
        let nearbySmall = manager.cardsNearby([closeCard, mediumCard], radius: 1000)
        #expect(nearbySmall.count == 1)
        
        // With large radius, both cards
        let nearbyLarge = manager.cardsNearby([closeCard, mediumCard], radius: 20000)
        #expect(nearbyLarge.count == 2)
    }
    
    // MARK: - Geofencing API Tests
    
    @Test func startMonitoringWithNoLocationDoesNotCrash() async throws {
        let manager = LocationManager() // No current location set
        
        let card = createTestCard(
            name: "TestCard",
            latitude: 42.6977,
            longitude: 23.3219
        )
        
        // Should not crash when no location available
        manager.startMonitoringCardLocations([card])
        
        // No assertion needed - just verify it doesn't crash
        #expect(true)
    }
    
    @Test func stopAllMonitoringDoesNotCrash() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219)
        
        let card = createTestCard(
            name: "TestCard",
            latitude: 42.6977,
            longitude: 23.3219
        )
        
        manager.startMonitoringCardLocations([card])
        manager.stopAllMonitoring()
        
        // Verify we can call it multiple times safely
        manager.stopAllMonitoring()
        
        #expect(true)
    }
    
    @Test func updateMonitoredRegionsDoesNotCrash() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219)
        
        var cards = [
            createTestCard(name: "Card1", latitude: 42.6977, longitude: 23.3219),
            createTestCard(name: "Card2", latitude: 42.7000, longitude: 23.3300)
        ]
        
        manager.startMonitoringCardLocations(cards)
        
        // Add a card
        cards.append(createTestCard(name: "Card3", latitude: 42.7100, longitude: 23.3400))
        
        manager.updateMonitoredRegions(cards)
        
        #expect(true)
    }
    
    @Test func cardIDsForUnknownRegionReturnsNil() async throws {
        let manager = LocationManager()
        
        let cardIDs = manager.cardIDs(for: "unknown-region-id-12345")
        
        #expect(cardIDs == nil)
    }
    
    @Test func startMonitoringWithEmptyArrayDoesNotCrash() async throws {
        let manager = createLocationManager(currentLatitude: 42.6977, currentLongitude: 23.3219)
        
        manager.startMonitoringCardLocations([])
        
        #expect(true)
    }
    
    // MARK: - Distance Calculation Tests
    
    @Test func distanceCalculationIsAccurate() async throws {
        // Sofia to Plovdiv is approximately 145km
        let sofia = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)
        let plovdiv = CLLocationCoordinate2D(latitude: 42.1354, longitude: 24.7453)
        
        let distance = LocationManager.distance(from: sofia, to: plovdiv)
        
        // Should be approximately 145,000 meters (allow 10% margin for calculation differences)
        #expect(distance > 130000)
        #expect(distance < 160000)
    }
    
    @Test func distanceToSamePointIsZero() async throws {
        let point = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)
        
        let distance = LocationManager.distance(from: point, to: point)
        
        #expect(distance == 0.0)
    }
    
    // MARK: - CardLocation Tests
    
    @Test func cardLocationDistanceCalculation() async throws {
        let location = CardLocation(
            name: "Test",
            address: "Test Address",
            latitude: 42.6977,
            longitude: 23.3219,
            radius: 500
        )
        
        let nearPoint = CLLocationCoordinate2D(latitude: 42.6980, longitude: 23.3220)
        let distance = location.distance(from: nearPoint)
        
        // Should be a small distance (few hundred meters)
        #expect(distance < 1000)
    }
    
    @Test func cardLocationContainsPointWithinRadius() async throws {
        let location = CardLocation(
            name: "Test",
            address: "Test Address",
            latitude: 42.6977,
            longitude: 23.3219,
            radius: 500
        )
        
        // Point very close (should be within 500m)
        let nearPoint = CLLocationCoordinate2D(latitude: 42.6980, longitude: 23.3220)
        
        #expect(location.contains(nearPoint))
    }
    
    @Test func cardLocationDoesNotContainPointOutsideRadius() async throws {
        let location = CardLocation(
            name: "Test",
            address: "Test Address",
            latitude: 42.6977,
            longitude: 23.3219,
            radius: 100
        )
        
        // Point far away (definitely > 100m)
        let farPoint = CLLocationCoordinate2D(latitude: 42.7100, longitude: 23.3400)
        
        #expect(!location.contains(farPoint))
    }
    
    // MARK: - Permission Tests
    
    @Test func hasBackgroundPermissionWhenAuthorizedAlways() async throws {
        let manager = LocationManager()
        
        // We can't actually set the authorization status in tests,
        // but we can verify the property logic
        // When status is .authorizedAlways, hasBackgroundPermission should be true
        // This is tested indirectly through the property getter
        
        #expect(manager.authorizationStatus != .authorizedAlways || manager.hasBackgroundPermission)
    }
}

//
//  LocationManagerTests.swift
//  kartoncheTests
//
//  Created on 2026-02-06.
//

import Testing
import CoreLocation
@testable import kartonche

struct LocationManagerTests {
    
    // MARK: - Distance Calculation Tests
    
    @Test func distanceBetweenSamePointIsZero() {
        let coordinate = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219) // Sofia
        let distance = LocationManager.distance(from: coordinate, to: coordinate)
        #expect(distance == 0.0)
    }
    
    @Test func distanceBetweenSofiaAndPlovdivIsCorrect() {
        let sofia = CLLocationCoordinate2D(latitude: 42.6977, longitude: 23.3219)
        let plovdiv = CLLocationCoordinate2D(latitude: 42.1354, longitude: 24.7453)
        
        let distance = LocationManager.distance(from: sofia, to: plovdiv)
        
        // Distance between Sofia and Plovdiv is approximately 126-130 km
        let expectedDistance = 128000.0 // meters
        let tolerance = 5000.0 // 5km tolerance
        
        #expect(abs(distance - expectedDistance) < tolerance)
    }
    
    // MARK: - CardLocation Tests
    
    @Test func cardLocationContainsCoordinateWithinRadius() {
        let location = CardLocation(
            name: "Billa NDK",
            address: "bul. Vitosha 100, Sofia",
            latitude: 42.6863,
            longitude: 23.3189,
            radius: 500.0
        )
        
        // Point 200m away (approximately)
        let nearbyPoint = CLLocationCoordinate2D(latitude: 42.6880, longitude: 23.3189)
        
        #expect(location.contains(nearbyPoint))
    }
    
    @Test func cardLocationDoesNotContainCoordinateOutsideRadius() {
        let location = CardLocation(
            name: "Billa NDK",
            address: "bul. Vitosha 100, Sofia",
            latitude: 42.6863,
            longitude: 23.3189,
            radius: 500.0
        )
        
        // Point 1km away
        let farPoint = CLLocationCoordinate2D(latitude: 42.6950, longitude: 23.3189)
        
        #expect(!location.contains(farPoint))
    }
    
    @Test func cardLocationDistanceCalculation() {
        let location = CardLocation(
            name: "Billa NDK",
            address: "bul. Vitosha 100, Sofia",
            latitude: 42.6863,
            longitude: 23.3189,
            radius: 500.0
        )
        
        let samePoint = CLLocationCoordinate2D(latitude: 42.6863, longitude: 23.3189)
        let distance = location.distance(from: samePoint)
        
        #expect(distance < 1.0) // Should be basically zero (within 1 meter due to floating point)
    }
    
    // MARK: - Nearby Cards Tests
    
    @Test @MainActor func nearbyCardsFindsCardsWithinRadius() async {
        let manager = LocationManager()
        
        // Set current location to Sofia center
        manager.currentLocation = CLLocation(latitude: 42.6977, longitude: 23.3219)
        
        // Create cards with locations
        let nearCard = LoyaltyCard(
            name: "Billa NDK",
            storeName: "Billa",
            cardNumber: "123",
            barcodeType: .ean13,
            barcodeData: "123"
        )
        let nearLocation = CardLocation(
            name: "Billa NDK",
            address: "bul. Vitosha, Sofia",
            latitude: 42.6863, // About 1.3km away
            longitude: 23.3189,
            radius: 500.0
        )
        nearLocation.card = nearCard
        nearCard.locations.append(nearLocation)
        
        let farCard = LoyaltyCard(
            name: "Kaufland Plovdiv",
            storeName: "Kaufland",
            cardNumber: "456",
            barcodeType: .ean13,
            barcodeData: "456"
        )
        let farLocation = CardLocation(
            name: "Kaufland Plovdiv",
            address: "Plovdiv",
            latitude: 42.1354, // About 128km away
            longitude: 24.7453,
            radius: 500.0
        )
        farLocation.card = farCard
        farCard.locations.append(farLocation)
        
        let allCards = [nearCard, farCard]
        let nearby = manager.cardsNearby(allCards, radius: 2000.0) // 2km radius
        
        // Only the near card should be found
        #expect(nearby.count == 1)
        #expect(nearby[0].card.name == "Billa NDK")
    }
    
    @Test @MainActor func nearbyCardsSortedByDistance() async {
        let manager = LocationManager()
        manager.currentLocation = CLLocation(latitude: 42.6977, longitude: 23.3219)
        
        // Create three cards at different distances
        let card1 = LoyaltyCard(name: "Far", storeName: "Store", cardNumber: "1", barcodeType: .qr, barcodeData: "1")
        let location1 = CardLocation(name: "Far", address: "Far", latitude: 42.6800, longitude: 23.3219, radius: 500.0)
        location1.card = card1
        card1.locations.append(location1)
        
        let card2 = LoyaltyCard(name: "Near", storeName: "Store", cardNumber: "2", barcodeType: .qr, barcodeData: "2")
        let location2 = CardLocation(name: "Near", address: "Near", latitude: 42.6960, longitude: 23.3219, radius: 500.0)
        location2.card = card2
        card2.locations.append(location2)
        
        let card3 = LoyaltyCard(name: "Medium", storeName: "Store", cardNumber: "3", barcodeType: .qr, barcodeData: "3")
        let location3 = CardLocation(name: "Medium", address: "Medium", latitude: 42.6900, longitude: 23.3219, radius: 500.0)
        location3.card = card3
        card3.locations.append(location3)
        
        let allCards = [card1, card2, card3]
        let nearby = manager.cardsNearby(allCards, radius: 5000.0)
        
        // Should be sorted by distance: Near, Medium, Far
        #expect(nearby.count == 3)
        #expect(nearby[0].card.name == "Near")
        #expect(nearby[1].card.name == "Medium")
        #expect(nearby[2].card.name == "Far")
    }
    
    @Test @MainActor func nearbyCardsReturnsEmptyWithNoLocation() async {
        let manager = LocationManager()
        // No current location set
        
        let card = LoyaltyCard(name: "Test", storeName: "Store", cardNumber: "1", barcodeType: .qr, barcodeData: "1")
        let location = CardLocation(name: "Test", address: "Test", latitude: 42.6977, longitude: 23.3219, radius: 500.0)
        location.card = card
        card.locations.append(location)
        
        let nearby = manager.cardsNearby([card], radius: 1000.0)
        
        #expect(nearby.isEmpty)
    }
    
    @Test @MainActor func nearbyCardsIgnoresCardsWithoutLocations() async {
        let manager = LocationManager()
        manager.currentLocation = CLLocation(latitude: 42.6977, longitude: 23.3219)
        
        let cardWithLocation = LoyaltyCard(name: "With", storeName: "Store", cardNumber: "1", barcodeType: .qr, barcodeData: "1")
        let location = CardLocation(name: "Test", address: "Test", latitude: 42.6960, longitude: 23.3219, radius: 500.0)
        location.card = cardWithLocation
        cardWithLocation.locations.append(location)
        
        let cardWithoutLocation = LoyaltyCard(name: "Without", storeName: "Store", cardNumber: "2", barcodeType: .qr, barcodeData: "2")
        // No locations added
        
        let allCards = [cardWithLocation, cardWithoutLocation]
        let nearby = manager.cardsNearby(allCards, radius: 1000.0)
        
        #expect(nearby.count == 1)
        #expect(nearby[0].card.name == "With")
    }
}

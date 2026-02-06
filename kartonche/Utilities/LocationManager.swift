//
//  LocationManager.swift
//  kartonche
//
//  Created on 2026-02-06.
//

import Foundation
import CoreLocation
import Combine
import UIKit

/// Manages location services for finding nearby cards
@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocation?
    @Published var lastError: Error?
    
    private let locationManager: CLLocationManager
    private var isRequestingLocation = false
    
    override init() {
        self.locationManager = CLLocationManager()
        self.authorizationStatus = locationManager.authorizationStatus
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    /// Request "When In Use" location permission
    func requestPermission() {
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Request current location (just-in-time)
    func requestLocation() {
        guard authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways else {
            if authorizationStatus == .notDetermined {
                requestPermission()
            }
            return
        }
        
        guard !isRequestingLocation else { return }
        isRequestingLocation = true
        locationManager.requestLocation()
    }
    
    /// Calculate distance in meters between two coordinates
    nonisolated static func distance(from: CLLocationCoordinate2D, to: CLLocationCoordinate2D) -> Double {
        let fromLocation = CLLocation(latitude: from.latitude, longitude: from.longitude)
        let toLocation = CLLocation(latitude: to.latitude, longitude: to.longitude)
        return fromLocation.distance(from: toLocation)
    }
    
    /// Find cards within a specified radius (in meters) from current location
    func cardsNearby(_ cards: [LoyaltyCard], radius: Double = 1000.0) -> [(card: LoyaltyCard, distance: Double)] {
        guard let currentLocation = currentLocation else { return [] }
        
        var nearbyCards: [(card: LoyaltyCard, distance: Double)] = []
        
        for card in cards {
            guard !card.locations.isEmpty else { continue }
            
            // Find the closest location for this card
            var closestDistance = Double.infinity
            for location in card.locations {
                let distance = location.distance(from: currentLocation.coordinate)
                if distance < closestDistance {
                    closestDistance = distance
                }
            }
            
            // Include if within radius
            if closestDistance <= radius {
                nearbyCards.append((card: card, distance: closestDistance))
            }
        }
        
        // Sort by distance (closest first)
        return nearbyCards.sorted { $0.distance < $1.distance }
    }
    
    /// Open system settings for location permissions
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            self.isRequestingLocation = false
            if let location = locations.last {
                self.currentLocation = location
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isRequestingLocation = false
            self.lastError = error
        }
    }
}

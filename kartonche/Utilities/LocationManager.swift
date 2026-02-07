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
import WidgetKit

/// Manages location services for finding nearby cards
@MainActor
class LocationManager: NSObject, ObservableObject {
    @Published var authorizationStatus: CLAuthorizationStatus
    @Published var currentLocation: CLLocation?
    @Published var lastError: Error?
    
    private let locationManager: CLLocationManager
    private var isRequestingLocation = false
    
    // Geofencing
    private var monitoredRegions: Set<String> = []
    private var regionToCardMapping: [String: [UUID]] = [:]
    private let maxGeofences = 20  // iOS limit
    
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
    
    /// Request "Always" location permission (for widgets)
    /// Call this only after "When In Use" permission is already granted
    func requestAlwaysPermission() {
        guard authorizationStatus == .authorizedWhenInUse else { return }
        locationManager.requestAlwaysAuthorization()
    }
    
    /// Check if background location permission is granted
    var hasBackgroundPermission: Bool {
        authorizationStatus == .authorizedAlways
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
    
    // MARK: - Geofencing
    
    /// Start monitoring geofences for card locations (requires .authorizedAlways)
    /// Monitors up to 20 closest locations to current position
    func startMonitoringCardLocations(_ cards: [LoyaltyCard]) {
        guard authorizationStatus == .authorizedAlways else { return }
        
        // Stop all existing monitoring
        stopAllMonitoring()
        
        // Collect all card locations
        var cardLocations: [(location: CardLocation, cardID: UUID)] = []
        for card in cards {
            for location in card.locations {
                cardLocations.append((location: location, cardID: card.id))
            }
        }
        
        // Sort by distance from current location (if available)
        if let currentLocation = currentLocation {
            cardLocations.sort { loc1, loc2 in
                let dist1 = loc1.location.distance(from: currentLocation.coordinate)
                let dist2 = loc2.location.distance(from: currentLocation.coordinate)
                return dist1 < dist2
            }
        }
        
        // Monitor up to 20 closest locations
        for (location, cardID) in cardLocations.prefix(maxGeofences) {
            startMonitoring(location: location, cardID: cardID)
        }
    }
    
    /// Start monitoring a single location
    private func startMonitoring(location: CardLocation, cardID: UUID) {
        let center = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
        let region = CLCircularRegion(
            center: center,
            radius: location.radius,
            identifier: location.id.uuidString
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true
        
        locationManager.startMonitoring(for: region)
        monitoredRegions.insert(region.identifier)
        
        // Map region to card(s) - multiple cards can share same location
        if regionToCardMapping[region.identifier] == nil {
            regionToCardMapping[region.identifier] = []
        }
        if !regionToCardMapping[region.identifier]!.contains(cardID) {
            regionToCardMapping[region.identifier]!.append(cardID)
        }
    }
    
    /// Stop monitoring all geofences
    func stopAllMonitoring() {
        for region in locationManager.monitoredRegions {
            locationManager.stopMonitoring(for: region)
        }
        monitoredRegions.removeAll()
        regionToCardMapping.removeAll()
    }
    
    /// Update monitored regions (call when user moves significantly)
    func updateMonitoredRegions(_ cards: [LoyaltyCard]) {
        guard authorizationStatus == .authorizedAlways else { return }
        
        // Re-evaluate closest 20 locations and restart monitoring
        startMonitoringCardLocations(cards)
    }
    
    /// Get card IDs associated with a region
    func cardIDs(for regionIdentifier: String) -> [UUID]? {
        return regionToCardMapping[regionIdentifier]
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
                
                // Save location for widget use
                SharedDataManager.saveLastKnownLocation(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
                
                // Reload widgets so they can use the new location
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.isRequestingLocation = false
            self.lastError = error
        }
    }
    
    // MARK: - Region Monitoring
    
    nonisolated func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        Task { @MainActor in
            // Get cards associated with this region
            if let cardIDs = self.cardIDs(for: circularRegion.identifier) {
                // Send notification
                await NotificationManager.shared.sendNearbyCardNotification(
                    for: cardIDs,
                    regionID: circularRegion.identifier
                )
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard let circularRegion = region as? CLCircularRegion else { return }
        
        Task { @MainActor in
            // Clear notification
            await NotificationManager.shared.clearNearbyCardNotification(
                regionID: circularRegion.identifier
            )
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Geofencing error for region \(region?.identifier ?? "unknown"): \(error)")
    }
}

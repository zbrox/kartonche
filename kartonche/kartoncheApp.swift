//
//  kartoncheApp.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import SwiftUI
import SwiftData
import UserNotifications
import UIKit
import Combine

@main
struct kartoncheApp: App {
    var sharedModelContainer: ModelContainer = SharedDataManager.createSharedModelContainer()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationDelegate = NotificationDelegate()
    @State private var urlRouter = URLRouter()
    @Environment(\.scenePhase) var scenePhase

    var body: some Scene {
        WindowGroup {
            CardListView()
                .onAppear {
                    // Request location on app launch to populate shared storage for widgets
                    // Only if we have cards with locations
                    if hasCardsWithLocations() {
                        locationManager.requestLocation()
                    }
                    
                    // Set notification delegate
                    UNUserNotificationCenter.current().delegate = notificationDelegate
                    
                    // Start geofencing if enabled
                    Task {
                        await startGeofencingIfEnabled()
                    }
                }
                .onChange(of: scenePhase) { oldPhase, newPhase in
                    if newPhase == .active {
                        // Refresh geofences when app becomes active
                        Task {
                            await refreshGeofences()
                        }
                    }
                }
                .environmentObject(locationManager)
                .environment(urlRouter)
                .onOpenURL { url in
                    urlRouter.handleURL(url)
                }
        }
        .modelContainer(sharedModelContainer)
        .handlesExternalEvents(matching: ["*"])
    }
    
    private func hasCardsWithLocations() -> Bool {
        let cards = SharedDataManager.fetchAllCards()
        return cards.contains(where: { !$0.locations.isEmpty })
    }
    
    /// Start geofencing if user has enabled nearby notifications
    private func startGeofencingIfEnabled() async {
        // Check if feature is enabled in user defaults
        guard UserDefaults.standard.bool(forKey: "nearbyCardNotificationsEnabled") else {
            return
        }
        
        // Check if we have required permissions
        guard locationManager.hasBackgroundPermission else { return }
        
        let notificationManager = NotificationManager.shared
        await notificationManager.updateAuthorizationStatus()
        guard notificationManager.authorizationStatus == .authorized else { return }
        
        // Get all cards and start monitoring
        let cards = SharedDataManager.fetchAllCards()
        locationManager.startMonitoringCardLocations(cards)
    }
    
    /// Refresh geofences based on current location
    private func refreshGeofences() async {
        // Only refresh if feature is enabled
        guard UserDefaults.standard.bool(forKey: "nearbyCardNotificationsEnabled") else {
            return
        }
        
        guard locationManager.hasBackgroundPermission else { return }
        
        // Update monitored regions (will re-evaluate closest 20)
        let cards = SharedDataManager.fetchAllCards()
        locationManager.updateMonitoredRegions(cards)
    }
}

/// Handles notification interactions
class NotificationDelegate: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    /// Handle notification tap when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        // Show notification even when app is in foreground
        return [.banner, .sound]
    }
    
    /// Handle notification tap - deep link to card
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        guard response.actionIdentifier == UNNotificationDefaultActionIdentifier else {
            return
        }
        
        let userInfo = response.notification.request.content.userInfo
        
        // Check notification type
        if let type = userInfo["type"] as? String {
            switch type {
            case "nearby_single":
                // Single nearby card - open card directly
                if let cardIDString = userInfo["cardID"] as? String,
                   let cardID = UUID(uuidString: cardIDString) {
                    if let url = URL(string: "kartonche://card?id=\(cardID.uuidString)") {
                        await UIApplication.shared.open(url)
                    }
                }
                
            case "nearby_multiple":
                // Multiple nearby cards - open app to nearby cards view
                if let cardIDStrings = userInfo["cardIDs"] as? [String] {
                    let ids = cardIDStrings.joined(separator: ",")
                    if let url = URL(string: "kartonche://nearby-cards?ids=\(ids)") {
                        await UIApplication.shared.open(url)
                    }
                }
                
            default:
                // Fallback for expiration notifications
                if let cardIDString = userInfo["cardID"] as? String,
                   let cardID = UUID(uuidString: cardIDString) {
                    if let url = URL(string: "kartonche://card?id=\(cardID.uuidString)") {
                        await UIApplication.shared.open(url)
                    }
                }
            }
        } else {
            // Legacy notification without type - assume expiration notification
            if let cardIDString = userInfo["cardID"] as? String,
               let cardID = UUID(uuidString: cardIDString) {
                if let url = URL(string: "kartonche://card?id=\(cardID.uuidString)") {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
}

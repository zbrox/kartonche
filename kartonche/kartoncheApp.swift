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
                }
                .environmentObject(locationManager)
        }
        .modelContainer(sharedModelContainer)
        .handlesExternalEvents(matching: ["*"])
    }
    
    private func hasCardsWithLocations() -> Bool {
        let cards = SharedDataManager.fetchAllCards()
        return cards.contains(where: { !$0.locations.isEmpty })
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
        
        // Extract card ID from userInfo
        if let cardIDString = response.notification.request.content.userInfo["cardID"] as? String,
           let cardID = UUID(uuidString: cardIDString) {
            // Open deep link to card
            if let url = URL(string: "kartonche://card?id=\(cardID.uuidString)") {
                await UIApplication.shared.open(url)
            }
        }
    }
}

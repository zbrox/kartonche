//
//  NotificationManager.swift
//  kartonche
//
//  Created on 2026-02-06.
//

import Foundation
import UserNotifications
import SwiftUI
import UIKit
import Combine

/// Manages local notifications for card expiration reminders
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let notificationCenter = UNUserNotificationCenter.current()
    
    private init() {
        Task {
            await checkAuthorizationStatus()
        }
    }
    
    /// Request notification permission from the user
    func requestPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound, .badge])
            await checkAuthorizationStatus()
            return granted
        } catch {
            print("Error requesting notification permission: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    /// Schedule expiration notifications for a card
    func scheduleExpirationNotifications(for card: LoyaltyCard) async {
        guard let expirationDate = card.expirationDate else { return }
        
        // Check permission status
        await checkAuthorizationStatus()
        
        // Only schedule if permission is granted
        // Don't request again here - permission should be requested when user enables expiration toggle
        guard authorizationStatus == .authorized else { return }
        
        // Cancel any existing notifications for this card
        await cancelNotifications(for: card)
        
        // Schedule 7-day warning
        await scheduleNotification(
            for: card,
            daysBeforeExpiration: 7,
            expirationDate: expirationDate
        )
        
        // Schedule 1-day warning
        await scheduleNotification(
            for: card,
            daysBeforeExpiration: 1,
            expirationDate: expirationDate
        )
    }
    
    /// Schedule a single notification
    private func scheduleNotification(
        for card: LoyaltyCard,
        daysBeforeExpiration days: Int,
        expirationDate: Date
    ) async {
        guard let notificationDate = Calendar.current.date(
            byAdding: .day,
            value: -days,
            to: expirationDate
        ) else { return }
        
        // Don't schedule if the notification date is in the past
        guard notificationDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        
        if days == 7 {
            content.title = String(localized: "Card Expiring Soon")
            content.body = String(format: String(localized: "Your %@ card expires in 7 days"), card.name)
        } else {
            content.title = String(localized: "Card Expires Tomorrow")
            content.body = String(format: String(localized: "Your %@ card expires tomorrow"), card.name)
        }
        
        content.sound = .default
        content.categoryIdentifier = "CARD_EXPIRATION"
        content.userInfo = ["cardID": card.id.uuidString]
        
        // Create trigger for specific date
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: notificationDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        
        // Create request with unique identifier
        let identifier = "\(card.id.uuidString)-\(days)days"
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        do {
            try await notificationCenter.add(request)
        } catch {
            print("Error scheduling notification: \(error)")
        }
    }
    
    /// Cancel all notifications for a specific card
    func cancelNotifications(for card: LoyaltyCard) async {
        let identifiers = [
            "\(card.id.uuidString)-7days",
            "\(card.id.uuidString)-1days"
        ]
        notificationCenter.removePendingNotificationRequests(withIdentifiers: identifiers)
    }
    
    /// Open system settings for notifications
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            UIApplication.shared.open(url)
        }
    }
}

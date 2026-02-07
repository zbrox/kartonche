//
//  NotificationManager.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import Foundation
import UserNotifications
import SwiftUI
import Combine

/// Manages local notifications for card expiration reminders
@MainActor
class NotificationManager: ObservableObject {
    static let shared = NotificationManager()
    
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    
    private let center = UNUserNotificationCenter.current()
    
    // Notification identifiers
    private func sevenDayIdentifier(for cardID: UUID) -> String {
        "expiration-7day-\(cardID.uuidString)"
    }
    
    private func oneDayIdentifier(for cardID: UUID) -> String {
        "expiration-1day-\(cardID.uuidString)"
    }
    
    private init() {
        Task {
            await updateAuthorizationStatus()
        }
    }
    
    // MARK: - Permission
    
    /// Request notification permission from user
    func requestPermission() async -> Bool {
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            await updateAuthorizationStatus()
            return granted
        } catch {
            print("Failed to request notification permission: \(error)")
            return false
        }
    }
    
    /// Check current authorization status
    func updateAuthorizationStatus() async {
        let settings = await center.notificationSettings()
        authorizationStatus = settings.authorizationStatus
    }
    
    // MARK: - Schedule Notifications
    
    /// Schedule expiration reminder notifications for a card
    func scheduleExpirationNotifications(for card: LoyaltyCard) async {
        guard let expirationDate = card.expirationDate else {
            // No expiration date, cancel any existing notifications
            await cancelNotifications(for: card.id)
            return
        }
        
        // Check if expiration is in the future
        guard expirationDate > Date() else {
            // Already expired, don't schedule
            await cancelNotifications(for: card.id)
            return
        }
        
        // Ensure we have permission
        guard authorizationStatus == .authorized else {
            return
        }
        
        // Cancel existing notifications first
        await cancelNotifications(for: card.id)
        
        // Schedule 7-day reminder
        if let sevenDaysBefore = Calendar.current.date(byAdding: .day, value: -7, to: expirationDate),
           sevenDaysBefore > Date() {
            await scheduleNotification(
                identifier: sevenDayIdentifier(for: card.id),
                title: String(localized: "Card Expiring Soon"),
                body: String(localized: "\(card.name) expires in 7 days"),
                date: sevenDaysBefore,
                cardID: card.id
            )
        }
        
        // Schedule 1-day reminder
        if let oneDayBefore = Calendar.current.date(byAdding: .day, value: -1, to: expirationDate),
           oneDayBefore > Date() {
            await scheduleNotification(
                identifier: oneDayIdentifier(for: card.id),
                title: String(localized: "Card Expires Tomorrow"),
                body: String(localized: "\(card.name) expires tomorrow"),
                date: oneDayBefore,
                cardID: card.id
            )
        }
    }
    
    /// Schedule a single notification
    private func scheduleNotification(
        identifier: String,
        title: String,
        body: String,
        date: Date,
        cardID: UUID
    ) async {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default
        
        // Add card ID to userInfo for deep linking
        content.userInfo = ["cardID": cardID.uuidString]
        
        // Create date components for trigger
        let components = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: date
        )
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        do {
            try await center.add(request)
            print("Scheduled notification: \(identifier) for \(date)")
        } catch {
            print("Failed to schedule notification: \(error)")
        }
    }
    
    // MARK: - Cancel Notifications
    
    /// Cancel all notifications for a specific card
    func cancelNotifications(for cardID: UUID) async {
        let identifiers = [
            sevenDayIdentifier(for: cardID),
            oneDayIdentifier(for: cardID)
        ]
        
        center.removePendingNotificationRequests(withIdentifiers: identifiers)
        print("Cancelled notifications for card: \(cardID)")
    }
    
    /// Cancel all scheduled notifications
    func cancelAllNotifications() async {
        center.removeAllPendingNotificationRequests()
        print("Cancelled all notifications")
    }
    
    // MARK: - Query Notifications
    
    /// Get count of pending notifications
    func getPendingNotificationCount() async -> Int {
        let requests = await center.pendingNotificationRequests()
        return requests.count
    }
    
    /// Get all pending notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        await center.pendingNotificationRequests()
    }
}

//
//  NotificationsSettingsView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import UIKit

struct NotificationsSettingsView: View {
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingNotificationPermission = false
    @State private var pendingNotificationCount = 0
    
    var body: some View {
        List {
            // Expiration Reminders Feature
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Expiration Reminders", comment: "Feature title for card expiration notifications"))
                            .font(.headline)
                        Text(featureStatusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    if notificationManager.authorizationStatus == .authorized {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                }
                
                if notificationManager.authorizationStatus == .authorized && pendingNotificationCount > 0 {
                    HStack {
                        Text(String(localized: "Scheduled reminders", comment: "Label showing count of pending expiration reminders"))
                            .font(.subheadline)
                        Spacer()
                        Text("\(pendingNotificationCount)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(String(localized: "Get reminded before your loyalty cards expire so you can renew them in time.", comment: "Description of the expiration reminders feature"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "Features", comment: "Section header in notification settings"))
            }

            // Permission Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Notification Permission", comment: "Label for notification permission status row"))
                            .font(.subheadline)
                        Text(permissionStatusText)
                            .font(.caption)
                            .foregroundStyle(permissionStatusColor)
                    }
                    
                    Spacer()
                    
                    if notificationManager.authorizationStatus == .notDetermined {
                        Button {
                            showingNotificationPermission = true
                        } label: {
                            Text(String(localized: "Enable", comment: "Button to request notification permission"))
                        }
                        .buttonStyle(.bordered)
                    } else if notificationManager.authorizationStatus == .denied {
                        Button {
                            openAppSettings()
                        } label: {
                            Text(String(localized: "Settings", comment: "Button to open device Settings for notification permission"))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                if notificationManager.authorizationStatus == .denied {
                    Text(String(localized: "Go to Settings > Notifications > kartonche to enable reminders", comment: "Instructions to fix denied notification permission in iOS Settings"))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text(String(localized: "Permission", comment: "Section header for notification permission status"))
            }
        }
        .navigationTitle(String(localized: "Notifications", comment: "Navigation title for notification settings screen"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingNotificationPermission) {
            NotificationPermissionView(
                onAllow: {
                    showingNotificationPermission = false
                    Task {
                        await requestNotificationPermission()
                    }
                },
                onDeny: {
                    showingNotificationPermission = false
                }
            )
            .presentationDetents([.medium])
        }
        .task {
            await loadNotificationInfo()
        }
    }
    
    private var featureStatusText: String {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return String(localized: "Active", comment: "Notification feature status: working")
        case .denied:
            return String(localized: "Permission required", comment: "Notification feature status: permission denied")
        case .notDetermined:
            return String(localized: "Not set up", comment: "Notification feature status: not yet configured")
        default:
            return String(localized: "Limited", comment: "Notification feature status: partially available")
        }
    }
    
    private var permissionStatusText: String {
        switch notificationManager.authorizationStatus {
        case .notDetermined:
            return String(localized: "Not Set", comment: "Notification permission status: not yet requested")
        case .denied:
            return String(localized: "Denied", comment: "Notification permission status: denied by user")
        case .authorized:
            return String(localized: "Enabled", comment: "Notification permission status: fully authorized")
        case .provisional:
            return String(localized: "Provisional", comment: "Notification permission status: provisional delivery")
        case .ephemeral:
            return String(localized: "Ephemeral", comment: "Notification permission status: ephemeral/temporary")
        @unknown default:
            return String(localized: "Unknown", comment: "Notification permission status: unrecognized value")
        }
    }
    
    private var permissionStatusColor: Color {
        switch notificationManager.authorizationStatus {
        case .authorized:
            return .green
        case .denied:
            return .orange
        default:
            return .secondary
        }
    }
    
    private func loadNotificationInfo() async {
        await notificationManager.updateAuthorizationStatus()
        pendingNotificationCount = await notificationManager.getPendingNotificationCount()
    }
    
    private func requestNotificationPermission() async {
        _ = await notificationManager.requestPermission()
        await loadNotificationInfo()
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                UIApplication.shared.open(url)
            }
        }
    }
}

#Preview {
    NavigationStack {
        NotificationsSettingsView()
    }
}

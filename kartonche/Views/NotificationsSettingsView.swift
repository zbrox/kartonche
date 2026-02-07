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
                        Text(String(localized: "Expiration Reminders"))
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
                        Text(String(localized: "Scheduled reminders"))
                            .font(.subheadline)
                        Spacer()
                        Text("\(pendingNotificationCount)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                
                Text(String(localized: "Get reminded before your loyalty cards expire so you can renew them in time."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "Features"))
            }
            
            // Permission Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Notification Permission"))
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
                            Text(String(localized: "Enable"))
                        }
                        .buttonStyle(.bordered)
                    } else if notificationManager.authorizationStatus == .denied {
                        Button {
                            openAppSettings()
                        } label: {
                            Text(String(localized: "Settings"))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                if notificationManager.authorizationStatus == .denied {
                    Text(String(localized: "Go to Settings > Notifications > kartonche to enable reminders"))
                        .font(.caption)
                        .foregroundStyle(.orange)
                }
            } header: {
                Text(String(localized: "Permission"))
            }
        }
        .navigationTitle(String(localized: "Notifications"))
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
            return String(localized: "Active")
        case .denied:
            return String(localized: "Permission required")
        case .notDetermined:
            return String(localized: "Not set up")
        default:
            return String(localized: "Limited")
        }
    }
    
    private var permissionStatusText: String {
        switch notificationManager.authorizationStatus {
        case .notDetermined:
            return String(localized: "Not Set")
        case .denied:
            return String(localized: "Denied")
        case .authorized:
            return String(localized: "Enabled")
        case .provisional:
            return String(localized: "Provisional")
        case .ephemeral:
            return String(localized: "Ephemeral")
        @unknown default:
            return String(localized: "Unknown")
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

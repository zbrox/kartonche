//
//  NotificationPermissionView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI

/// View that explains notification permission and requests it
struct NotificationPermissionView: View {
    let onAllow: () -> Void
    let onDeny: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                .padding(.top, 48)
            
            Text(String(localized: "Expiration Reminders", comment: "Title on the notification permission request screen."))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "Get notified before your cards expire so you never miss renewing them.", comment: "Description on the notification permission request screen."))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "We'll remind you:", comment: "Label above the list of reminder timing options."))
                        .fontWeight(.semibold)
                    
                    Label(String(localized: "7 days before expiration", comment: "Reminder timing option on the notification permission screen."), systemImage: "calendar.badge.clock")
                    Label(String(localized: "1 day before expiration", comment: "Reminder timing option on the notification permission screen."), systemImage: "clock.badge.exclamationmark")
                    Label(String(localized: "Tap notification to view card", comment: "Feature description on the notification permission screen."), systemImage: "hand.tap")
                }
                .font(.subheadline)
                
                Text(String(localized: "You can disable reminders anytime in Settings.", comment: "Reassurance note on the notification permission screen."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    onAllow()
                } label: {
                    Text(String(localized: "Enable Reminders", comment: "Button to grant notification permission."))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onDeny()
                } label: {
                    Text(String(localized: "Not Now", comment: "Button to dismiss the notification permission screen."))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding()
    }
}

/// View shown when notification permission is denied
struct NotificationPermissionDeniedView: View {
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "bell.slash.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
                .padding(.top, 48)
            
            Text(String(localized: "Notifications Disabled", comment: "Title on the notification permission denied screen."))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "Expiration reminders require notification access.", comment: "Explanation on the notification permission denied screen."))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Enable in Settings:", comment: "Label above navigation path for enabling notifications."))
                        .fontWeight(.semibold)

                    Text(String(localized: "Settings > Notifications > kartonche", comment: "Navigation path to enable notifications in iOS Settings."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
            .fixedSize(horizontal: false, vertical: true)
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    onOpenSettings()
                } label: {
                    Text(String(localized: "Open Settings", comment: "Button to open iOS Settings from the notification denied screen."))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    onCancel()
                } label: {
                    Text(String(localized: "Cancel", comment: "Button to dismiss the notification permission denied screen."))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding()
    }
}

#Preview("Permission Request") {
    NotificationPermissionView(
        onAllow: { print("Allow") },
        onDeny: { print("Deny") }
    )
}

#Preview("Permission Denied") {
    NotificationPermissionDeniedView(
        onOpenSettings: { print("Open Settings") },
        onCancel: { print("Cancel") }
    )
}

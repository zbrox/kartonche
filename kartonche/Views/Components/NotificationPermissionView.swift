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
                .padding(.top, 8)
            
            Text(String(localized: "Expiration Reminders"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "Get notified before your cards expire so you never miss renewing them."))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "We'll remind you:"))
                        .fontWeight(.semibold)
                    
                    Label(String(localized: "7 days before expiration"), systemImage: "calendar.badge.clock")
                    Label(String(localized: "1 day before expiration"), systemImage: "clock.badge.exclamationmark")
                    Label(String(localized: "Tap notification to view card"), systemImage: "hand.tap")
                }
                .font(.subheadline)
                
                Text(String(localized: "You can disable reminders anytime in Settings."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    onAllow()
                } label: {
                    Text(String(localized: "Enable Reminders"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onDeny()
                } label: {
                    Text(String(localized: "Not Now"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
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
                .padding(.top, 8)
            
            Text(String(localized: "Notifications Disabled"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "Expiration reminders require notification access."))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Enable in Settings:"))
                        .fontWeight(.semibold)
                    
                    Text(String(localized: "Settings > Notifications > kartonche"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .font(.subheadline)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    onOpenSettings()
                } label: {
                    Text(String(localized: "Open Settings"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onCancel()
                } label: {
                    Text(String(localized: "Cancel"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
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

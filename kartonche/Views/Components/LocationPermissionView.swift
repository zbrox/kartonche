//
//  LocationPermissionView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI

/// View that explains location permission and requests it
struct LocationPermissionView: View {
    let onAllow: () -> Void
    let onDeny: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.blue)
            
            Text(String(localized: "Location Permission Needed"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: "To save card locations, kartonche needs to access your location."))
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "This helps you:"))
                        .fontWeight(.semibold)
                    
                    Label(String(localized: "See cards when you're nearby"), systemImage: "mappin.and.ellipse")
                    Label(String(localized: "Auto-show the right card"), systemImage: "sparkles")
                    Label(String(localized: "Find nearest card in widgets"), systemImage: "apps.iphone")
                }
                
                Text(String(localized: "Your location is only used to calculate distance to saved stores."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: 12) {
                Button {
                    onAllow()
                } label: {
                    Text(String(localized: "Allow Location"))
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
        }
        .padding(32)
    }
}

/// View shown when location permission is denied
struct LocationPermissionDeniedView: View {
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(.orange)
            
            Text(String(localized: "Location Access Denied"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 16) {
                Text(String(localized: "Location features require access to your location."))
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text(String(localized: "Enable in Settings:"))
                        .fontWeight(.semibold)
                    
                    Text(String(localized: "Settings > kartonche > Location > While Using the App"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
            
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
        }
        .padding(32)
    }
}

#Preview("Permission Request") {
    LocationPermissionView(
        onAllow: { print("Allow") },
        onDeny: { print("Deny") }
    )
}

#Preview("Permission Denied") {
    LocationPermissionDeniedView(
        onOpenSettings: { print("Open Settings") },
        onCancel: { print("Cancel") }
    )
}

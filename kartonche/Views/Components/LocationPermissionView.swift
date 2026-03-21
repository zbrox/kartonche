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
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                .padding(.top, 48)
            
            Text(String(localized: "Location Permission Needed", comment: "Title on the location permission request screen."))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "To save card locations, kartonche needs to access your location.", comment: "Description on the location permission request screen."))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "This helps you:", comment: "Label above the list of location feature benefits."))
                        .fontWeight(.semibold)
                    
                    Label(String(localized: "See cards when you're nearby", comment: "Location feature benefit on the permission screen."), systemImage: "mappin.and.ellipse")
                    Label(String(localized: "Auto-show the right card", comment: "Location feature benefit on the permission screen."), systemImage: "sparkles")
                    Label(String(localized: "Find nearest card in widgets", comment: "Location feature benefit on the permission screen."), systemImage: "apps.iphone")
                }
                .font(.subheadline)
                
                Text(String(localized: "Your location is only used to calculate distance to saved stores.", comment: "Privacy reassurance on the location permission screen."))
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
                    Text(String(localized: "Allow Location", comment: "Button to grant location permission."))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onDeny()
                } label: {
                    Text(String(localized: "Not Now", comment: "Button to dismiss the location permission screen."))
                        .frame(maxWidth: .infinity)
                }
                .accessibilityIdentifier("locationPermissionDeny")
                .buttonStyle(.bordered)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding()
    }
}

/// View shown when location permission is denied
struct LocationPermissionDeniedView: View {
    let onOpenSettings: () -> Void
    let onCancel: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.slash.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.orange)
                .padding(.top, 48)
            
            Text(String(localized: "Location Access Denied", comment: "Title on the location permission denied screen."))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "Location features require access to your location.", comment: "Explanation on the location permission denied screen."))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Enable in Settings:", comment: "Label above navigation path for enabling location access."))
                        .fontWeight(.semibold)

                    Text(String(localized: "Settings > kartonche > Location > While Using the App", comment: "Navigation path to enable location in iOS Settings."))
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
                    Text(String(localized: "Open Settings", comment: "Button to open iOS Settings from the location denied screen."))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    onCancel()
                } label: {
                    Text(String(localized: "Cancel", comment: "Button to dismiss the location permission denied screen."))
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

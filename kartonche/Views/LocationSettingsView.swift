//
//  LocationSettingsView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import CoreLocation
import UIKit

struct LocationSettingsView: View {
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @AppStorage("nearbyCardNotificationsEnabled") private var nearbyNotificationsEnabled = false
    
    @State private var showingLocationPermission = false
    @State private var showingAlwaysExplanation = false
    @State private var showingNearbyNotificationsExplanation = false
    
    private var canEnableNearbyNotifications: Bool {
        locationManager.authorizationStatus == .authorizedAlways &&
        notificationManager.authorizationStatus == .authorized
    }
    
    var body: some View {
        List {
            // Features Section
            Section {
                // Nearby Card Notifications
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Nearby Card Notifications", comment: "Feature title for location-based card reminders"))
                            .font(.headline)
                        Text(nearbyNotificationStatusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: Binding(
                        get: { nearbyNotificationsEnabled },
                        set: { newValue in
                            if newValue {
                                showingNearbyNotificationsExplanation = true
                            } else {
                                nearbyNotificationsEnabled = false
                                locationManager.stopAllMonitoring()
                            }
                        }
                    ))
                    .disabled(!canEnableNearbyNotifications)
                }
                
                if !canEnableNearbyNotifications {
                    if locationManager.authorizationStatus != .authorizedAlways {
                        Text(String(localized: "'Always' location permission required for nearby notifications", comment: "Warning when always-on location permission is needed"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    } else if notificationManager.authorizationStatus != .authorized {
                        Text(String(localized: "Notification permission required", comment: "Warning when notification permission is needed for nearby alerts"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                } else if nearbyNotificationsEnabled {
                    Text(String(localized: "You'll be notified when you're near a saved card location", comment: "Status text when nearby notifications are active"))
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                
                Text(String(localized: "Get reminded about your loyalty cards when you're near a store where you can use them.", comment: "Description of nearby card notifications feature"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "Features", comment: "Section header in location settings"))
            }
            
            // Permission Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Location Permission", comment: "Label for location permission status row"))
                            .font(.subheadline)
                        Text(permissionStatusText)
                            .font(.caption)
                            .foregroundStyle(permissionStatusColor)
                    }
                    
                    Spacer()
                    
                    if locationManager.authorizationStatus == .notDetermined {
                        Button {
                            showingLocationPermission = true
                        } label: {
                            Text(String(localized: "Enable", comment: "Button to request location permission"))
                        }
                        .buttonStyle(.bordered)
                    } else if locationManager.authorizationStatus == .denied {
                        Button {
                            openAppSettings()
                        } label: {
                            Text(String(localized: "Settings", comment: "Button to open device Settings app for location permission"))
                        }
                        .buttonStyle(.bordered)
                    } else if locationManager.authorizationStatus == .authorizedWhenInUse {
                        Button {
                            showingAlwaysExplanation = true
                        } label: {
                            Text(String(localized: "Upgrade", comment: "Button to upgrade from when-in-use to always location permission"))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Status-specific help text
                if locationManager.authorizationStatus == .notDetermined {
                    Text(String(localized: "Enable location to see cards for nearby stores", comment: "Help text when location permission is not yet requested"))
                        .font(.caption)
                        .foregroundStyle(.blue)
                } else if locationManager.authorizationStatus == .denied {
                    Text(String(localized: "Settings > kartonche > Location > While Using the App", comment: "Instructions to fix denied location permission in iOS Settings"))
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else if locationManager.authorizationStatus == .restricted {
                    Text(String(localized: "Location access is restricted by parental controls or device management", comment: "Help text when location is restricted by MDM or parental controls"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if locationManager.authorizationStatus == .authorizedWhenInUse {
                    Text(String(localized: "Upgrade to 'Always' for nearby notifications and better widget performance", comment: "Help text suggesting always-on location for better experience"))
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            } header: {
                Text(String(localized: "Permission", comment: "Section header for location permission status"))
            }
            
            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label(String(localized: "Your location is only used to find nearby stores", comment: "Privacy assurance about location data usage"), systemImage: "checkmark.shield")
                    Label(String(localized: "Location data never leaves your device", comment: "Privacy assurance about location data storage"), systemImage: "checkmark.shield")
                    Label(String(localized: "Minimal battery impact", comment: "Privacy assurance about battery usage"), systemImage: "checkmark.shield")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "Privacy", comment: "Section header for privacy information about location"))
            }
        }
        .navigationTitle(String(localized: "Location", comment: "Navigation title for location settings screen"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingLocationPermission) {
            LocationPermissionView(
                onAllow: {
                    showingLocationPermission = false
                    locationManager.requestPermission()
                },
                onDeny: {
                    showingLocationPermission = false
                }
            )
            .presentationDetents([.medium])
        }
        .sheet(isPresented: $showingAlwaysExplanation) {
            AlwaysLocationExplanationView(locationManager: locationManager)
        }
        .sheet(isPresented: $showingNearbyNotificationsExplanation) {
            NearbyNotificationsExplanationView(
                onEnable: {
                    UserDefaults.standard.set(true, forKey: "nearbyCardNotificationsEnabled")
                    showingNearbyNotificationsExplanation = false
                    let cards = SharedDataManager.fetchAllCards()
                    locationManager.startMonitoringCardLocations(cards)
                },
                onNotNow: {
                    showingNearbyNotificationsExplanation = false
                }
            )
            .presentationDetents([.medium])
        }
    }
    
    private var permissionStatusText: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return String(localized: "Not Set", comment: "Location permission status: not yet requested")
        case .restricted:
            return String(localized: "Restricted", comment: "Location permission status: restricted by system")
        case .denied:
            return String(localized: "Denied", comment: "Location permission status: denied by user")
        case .authorizedWhenInUse:
            return String(localized: "While Using App", comment: "Location permission status: only while app is open")
        case .authorizedAlways:
            return String(localized: "Always", comment: "Location permission status: always available")
        @unknown default:
            return String(localized: "Unknown", comment: "Location permission status: unrecognized value")
        }
    }
    
    private var permissionStatusColor: Color {
        switch locationManager.authorizationStatus {
        case .authorizedAlways:
            return .green
        case .authorizedWhenInUse:
            return .blue
        case .denied:
            return .orange
        default:
            return .secondary
        }
    }
    
    private var nearbyNotificationStatusText: String {
        if !canEnableNearbyNotifications {
            return String(localized: "Requires Always location + Notifications", comment: "Status when prerequisites for nearby notifications are not met")
        }
        return nearbyNotificationsEnabled ?
            String(localized: "Enabled", comment: "Nearby notifications toggle status: on") :
            String(localized: "Disabled", comment: "Nearby notifications toggle status: off")
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                UIApplication.shared.open(url)
            }
        }
    }
}

struct AlwaysLocationExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                .padding(.top, 48)
            
            Text(String(localized: "Upgrade to 'Always' Location", comment: "Title of sheet explaining always-on location benefits"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Better Widget Performance:", comment: "Heading for list of always-on location benefits"))
                        .fontWeight(.semibold)

                    Label(String(localized: "Widgets work when app is closed", comment: "Benefit of always-on location"), systemImage: "apps.iphone")
                    Label(String(localized: "Fresher location data", comment: "Benefit of always-on location"), systemImage: "arrow.clockwise")
                    Label(String(localized: "More accurate nearby store detection", comment: "Benefit of always-on location"), systemImage: "location.fill")
                }
                .font(.subheadline)
                
                Text(String(localized: "Your location is only used to find nearby stores. Battery impact is minimal.", comment: "Privacy note in always-on location explanation sheet"))
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
                    locationManager.openSettings()
                    dismiss()
                } label: {
                    Text(String(localized: "Open Settings", comment: "Button to open iOS Settings to change location permission"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)

                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "Keep Current", comment: "Button to keep current location permission and dismiss"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)

                Text(String(localized: "Select 'Location' then choose 'Always'", comment: "Instruction text guiding user through iOS Settings"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
            .padding(.bottom, 16)
        }
        .padding()
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    NavigationStack {
        LocationSettingsView()
    }
}

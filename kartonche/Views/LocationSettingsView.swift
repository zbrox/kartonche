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
                        Text(String(localized: "Nearby Card Notifications"))
                            .font(.headline)
                        Text(nearbyNotificationStatusText)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    
                    Spacer()
                    
                    Toggle("", isOn: $nearbyNotificationsEnabled)
                        .disabled(!canEnableNearbyNotifications)
                        .onChange(of: nearbyNotificationsEnabled) { oldValue, newValue in
                            handleNearbyNotificationsToggle(newValue)
                        }
                }
                
                if !canEnableNearbyNotifications {
                    if locationManager.authorizationStatus != .authorizedAlways {
                        Text(String(localized: "'Always' location permission required for nearby notifications"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    } else if notificationManager.authorizationStatus != .authorized {
                        Text(String(localized: "Notification permission required"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                } else if nearbyNotificationsEnabled {
                    Text(String(localized: "You'll be notified when you're near a saved card location"))
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
                
                Text(String(localized: "Get reminded about your loyalty cards when you're near a store where you can use them."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "Features"))
            }
            
            // Permission Section
            Section {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(String(localized: "Location Permission"))
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
                            Text(String(localized: "Enable"))
                        }
                        .buttonStyle(.bordered)
                    } else if locationManager.authorizationStatus == .denied {
                        Button {
                            openAppSettings()
                        } label: {
                            Text(String(localized: "Settings"))
                        }
                        .buttonStyle(.bordered)
                    } else if locationManager.authorizationStatus == .authorizedWhenInUse {
                        Button {
                            showingAlwaysExplanation = true
                        } label: {
                            Text(String(localized: "Upgrade"))
                        }
                        .buttonStyle(.bordered)
                    }
                }
                
                // Status-specific help text
                if locationManager.authorizationStatus == .notDetermined {
                    Text(String(localized: "Enable location to see cards for nearby stores"))
                        .font(.caption)
                        .foregroundStyle(.blue)
                } else if locationManager.authorizationStatus == .denied {
                    Text(String(localized: "Settings > kartonche > Location > While Using the App"))
                        .font(.caption)
                        .foregroundStyle(.orange)
                } else if locationManager.authorizationStatus == .restricted {
                    Text(String(localized: "Location access is restricted by parental controls or device management"))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                } else if locationManager.authorizationStatus == .authorizedWhenInUse {
                    Text(String(localized: "Upgrade to 'Always' for nearby notifications and better widget performance"))
                        .font(.caption)
                        .foregroundStyle(.blue)
                }
            } header: {
                Text(String(localized: "Permission"))
            }
            
            // Info Section
            Section {
                VStack(alignment: .leading, spacing: 8) {
                    Label(String(localized: "Your location is only used to find nearby stores"), systemImage: "checkmark.shield")
                    Label(String(localized: "Location data never leaves your device"), systemImage: "checkmark.shield")
                    Label(String(localized: "Minimal battery impact"), systemImage: "checkmark.shield")
                }
                .font(.caption)
                .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "Privacy"))
            }
        }
        .navigationTitle(String(localized: "Location"))
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
                    nearbyNotificationsEnabled = true
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
            return String(localized: "Not Set")
        case .restricted:
            return String(localized: "Restricted")
        case .denied:
            return String(localized: "Denied")
        case .authorizedWhenInUse:
            return String(localized: "While Using App")
        case .authorizedAlways:
            return String(localized: "Always")
        @unknown default:
            return String(localized: "Unknown")
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
            return String(localized: "Requires Always location + Notifications")
        }
        return nearbyNotificationsEnabled ?
            String(localized: "Enabled") :
            String(localized: "Disabled")
    }
    
    private func handleNearbyNotificationsToggle(_ enabled: Bool) {
        if enabled {
            if !UserDefaults.standard.bool(forKey: "hasSeenNearbyNotificationsPrompt") {
                showingNearbyNotificationsExplanation = true
                nearbyNotificationsEnabled = false
                UserDefaults.standard.set(true, forKey: "hasSeenNearbyNotificationsPrompt")
            } else {
                let cards = SharedDataManager.fetchAllCards()
                locationManager.startMonitoringCardLocations(cards)
            }
        } else {
            locationManager.stopAllMonitoring()
        }
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
                .padding(.top, 8)
            
            Text(String(localized: "Upgrade to 'Always' Location"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "Better Widget Performance:"))
                        .fontWeight(.semibold)
                    
                    Label(String(localized: "Widgets work when app is closed"), systemImage: "apps.iphone")
                    Label(String(localized: "Fresher location data"), systemImage: "arrow.clockwise")
                    Label(String(localized: "More accurate nearby store detection"), systemImage: "location.fill")
                }
                .font(.subheadline)
                
                Text(String(localized: "Your location is only used to find nearby stores. Battery impact is minimal."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    locationManager.openSettings()
                    dismiss()
                } label: {
                    Text(String(localized: "Open Settings"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    dismiss()
                } label: {
                    Text(String(localized: "Keep Current"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                
                Text(String(localized: "Select 'Location' then choose 'Always'"))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal)
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

//
//  SettingsView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import CoreLocation
import UIKit

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @StateObject private var notificationManager = NotificationManager.shared
    @State private var showingAlwaysExplanation = false
    @State private var showingNotificationPermission = false
    @State private var showingLocationPermission = false
    @State private var pendingNotificationCount = 0
    @State private var notificationsEnabled = false
    
    var body: some View {
        NavigationStack {
            Form {
                // Notification Settings
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Expiration Reminders"))
                                .font(.headline)
                            Text(notificationStatusText)
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
                    
                    if notificationManager.authorizationStatus == .denied {
                        Text(String(localized: "Go to Settings > Notifications > kartonche to enable reminders"))
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }
                } header: {
                    Text(String(localized: "Notifications"))
                }
                
                // Location Settings
                Section {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(String(localized: "Location Permission"))
                                .font(.headline)
                            Text(locationPermissionStatus)
                                .font(.caption)
                                .foregroundStyle(.secondary)
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
                    
                    if locationManager.authorizationStatus == .notDetermined {
                        Text(String(localized: "Enable location to see nearby cards and use location features"))
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
                        Text(String(localized: "Upgrade to 'Always' for better widget performance"))
                            .font(.caption)
                            .foregroundStyle(.blue)
                    }
                } header: {
                    Text(String(localized: "Permissions"))
                }
                
                Section {
                    Text(String(localized: "Version \(appVersion)"))
                        .foregroundStyle(.secondary)
                } header: {
                    Text(String(localized: "About"))
                }
            }
            .navigationTitle(String(localized: "Settings"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done")) {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showingAlwaysExplanation) {
                AlwaysLocationExplanationView(locationManager: locationManager)
            }
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
    }
    
    private var notificationStatusText: String {
        switch notificationManager.authorizationStatus {
        case .notDetermined:
            return String(localized: "Not Set")
        case .denied:
            return String(localized: "Disabled")
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
    
    private func loadNotificationInfo() async {
        await notificationManager.updateAuthorizationStatus()
        pendingNotificationCount = await notificationManager.getPendingNotificationCount()
        notificationsEnabled = notificationManager.authorizationStatus == .authorized
    }
    
    private func requestNotificationPermission() async {
        let granted = await notificationManager.requestPermission()
        if granted {
            await loadNotificationInfo()
        }
    }
    
    private func openAppSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            Task { @MainActor in
                UIApplication.shared.open(url)
            }
        }
    }
    
    private var locationPermissionStatus: String {
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
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

struct AlwaysLocationExplanationView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var locationManager: LocationManager
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()
                
                Image(systemName: "location.circle.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(.blue)
                
                Text(String(localized: "Upgrade to 'Always' Location"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(String(localized: "Better Widget Performance:"))
                            .fontWeight(.semibold)
                        
                        Label(String(localized: "Widgets work when app is closed"), systemImage: "apps.iphone")
                        Label(String(localized: "Fresher location data"), systemImage: "arrow.clockwise")
                        Label(String(localized: "More accurate nearby cards"), systemImage: "location.fill")
                    }
                    
                    Text(String(localized: "Your location is only used to find nearby cards. Battery impact is minimal."))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button {
                        locationManager.requestAlwaysPermission()
                        dismiss()
                    } label: {
                        Text(String(localized: "Upgrade to Always"))
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
                }
                .padding()
            }
            .padding()
            .navigationBarTitleDisplayMode(.inline)
        }
        .presentationDetents([.medium, .large])
    }
}

#Preview {
    SettingsView()
}

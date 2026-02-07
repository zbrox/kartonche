//
//  SettingsView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import CoreLocation

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var locationManager = LocationManager()
    @State private var showingAlwaysExplanation = false
    
    var body: some View {
        NavigationStack {
            Form {
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
                        
                        if locationManager.authorizationStatus == .authorizedWhenInUse {
                            Button {
                                showingAlwaysExplanation = true
                            } label: {
                                Text(String(localized: "Upgrade"))
                            }
                            .buttonStyle(.bordered)
                        }
                    }
                    
                    if locationManager.authorizationStatus == .authorizedWhenInUse {
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

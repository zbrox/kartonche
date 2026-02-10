//
//  SettingsView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                // Settings Submenus
                Section {
                    NavigationLink {
                        NotificationsSettingsView()
                    } label: {
                        Label(String(localized: "Notifications"), systemImage: "bell.badge")
                    }
                    
                    NavigationLink {
                        LocationSettingsView()
                    } label: {
                        Label(String(localized: "Location"), systemImage: "location")
                    }
                }
                
                // Data
                Section {
                    NavigationLink {
                        DataSettingsView()
                    } label: {
                        Label(String(localized: "Data"), systemImage: "externaldrive")
                    }
                }

                // About
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label(String(localized: "About"), systemImage: "info.circle")
                    }
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
        }
    }
}

#Preview {
    SettingsView()
}

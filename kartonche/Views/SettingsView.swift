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
                        Label(String(localized: "Notifications", comment: "Settings row to open notification settings"), systemImage: "bell.badge")
                    }
                    
                    NavigationLink {
                        LocationSettingsView()
                    } label: {
                        Label(String(localized: "Location", comment: "Settings row to open location settings"), systemImage: "location")
                    }
                }
                
                // Data
                Section {
                    NavigationLink {
                        DataSettingsView()
                    } label: {
                        Label(String(localized: "Data", comment: "Settings row to open data management (export/import)"), systemImage: "externaldrive")
                    }
                    .accessibilityIdentifier("dataSettingsRow")
                }

                // About
                Section {
                    NavigationLink {
                        AboutView()
                    } label: {
                        Label(String(localized: "About", comment: "Settings row to open About screen"), systemImage: "info.circle")
                    }
                }

                #if DEBUG
                Section {
                    NavigationLink {
                        DebugSettingsView()
                    } label: {
                        Label("Debug", systemImage: "ant")
                    }
                }
                #endif
            }
            .navigationTitle(String(localized: "Settings", comment: "Navigation title for settings screen"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", comment: "Button to dismiss settings")) {
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

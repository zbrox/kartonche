//
//  AboutView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI
import StoreKit

struct AboutView: View {
    @Environment(\.requestReview) private var requestReview
    @State private var showingLicense = false
    @State private var showingPrivacy = false
    @State private var showingWhatsNew = false
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
    
    private var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
    }
    
    var body: some View {
        List {
            // App Header
            Section {
                VStack(spacing: 12) {
                    Image("AboutIcon")
                        .resizable()
                        .frame(width: 80, height: 80)
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color.primary.opacity(0.1), lineWidth: 1)
                        )
                    
                    Text("kartonche")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(String(localized: "Version \(appVersion) (\(buildNumber))"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .listRowBackground(Color.clear)
            }
            
            // About Section
            Section {
                Text(String(localized: "A simple app for organizing your loyalty cards. Open source, privacy-focused, no account required."))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            } header: {
                Text(String(localized: "About"))
            }
            
            // Legal Section
            Section {
                Button {
                    showingLicense = true
                } label: {
                    Label(String(localized: "License"), systemImage: "doc.text")
                }
                .foregroundStyle(.primary)
                
                Button {
                    showingPrivacy = true
                } label: {
                    Label(String(localized: "Privacy"), systemImage: "hand.raised")
                }
                .foregroundStyle(.primary)
            } header: {
                Text(String(localized: "Legal"))
            }
            
            // Support Section
            Section {
                Button {
                    requestReview()
                } label: {
                    Label(String(localized: "Rate on App Store"), systemImage: "star")
                }
                .foregroundStyle(.primary)
                
                Link(destination: URL(string: "https://github.com/zbrox/kartonche/issues")!) {
                    Label(String(localized: "Report an Issue"), systemImage: "ladybug")
                }
                .foregroundStyle(.primary)
                
                Button {
                    // Placeholder for future donation link
                } label: {
                    Label(String(localized: "Support Development"), systemImage: "cup.and.saucer")
                }
                .foregroundStyle(.secondary)
                .disabled(true)
            } header: {
                Text(String(localized: "Support"))
            }
            
            // More Section
            Section {
                Button {
                    showingWhatsNew = true
                } label: {
                    Label(String(localized: "What's New"), systemImage: "sparkles")
                }
                .foregroundStyle(.primary)
                
                Link(destination: URL(string: "https://github.com/zbrox/kartonche")!) {
                    Label(String(localized: "Source Code"), systemImage: "chevron.left.forwardslash.chevron.right")
                }
                .foregroundStyle(.primary)
            } header: {
                Text(String(localized: "More"))
            }
            
            // Credits
            Section {
                Text(String(localized: "Thanks to early testers and friends who provided feedback."))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .listRowBackground(Color.clear)
            }
        }
        .navigationTitle(String(localized: "About"))
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingLicense) {
            LicenseView()
        }
        .sheet(isPresented: $showingPrivacy) {
            PrivacyView()
        }
        .sheet(isPresented: $showingWhatsNew) {
            WhatsNewView()
        }
    }
}

struct LicenseView: View {
    @Environment(\.dismiss) private var dismiss
    
    private let licenseText = """
    MIT License
    
    Copyright (c) 2026 Rostislav Raykov
    
    Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
    
    The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
    
    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
    """
    
    var body: some View {
        NavigationStack {
            ScrollView {
                Text(licenseText)
                    .font(.footnote)
                    .padding()
            }
            .navigationTitle(String(localized: "MIT License"))
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

struct PrivacyView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Text(String(localized: "Privacy Policy"))
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        Text(String(localized: "kartonche stores all data locally on your device. We don't collect, track, or share any personal information."))
                        
                        Text(String(localized: "No account required"))
                            .fontWeight(.semibold)
                        Text(String(localized: "Your cards are stored only on your device."))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "No analytics"))
                            .fontWeight(.semibold)
                        Text(String(localized: "We don't track how you use the app."))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "No ads"))
                            .fontWeight(.semibold)
                        Text(String(localized: "The app contains no advertising."))
                            .foregroundStyle(.secondary)
                        
                        Text(String(localized: "Location data"))
                            .fontWeight(.semibold)
                        Text(String(localized: "If you enable location features, your location is used only to show cards for nearby stores and is never sent to any server."))
                            .foregroundStyle(.secondary)
                    }
                    .font(.subheadline)
                }
                .padding()
            }
            .navigationTitle(String(localized: "Privacy"))
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

struct WhatsNewView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(whatsNewVersions, id: \.version) { version in
                    Section {
                        ForEach(version.features, id: \.icon) { feature in
                            FeatureRow(
                                icon: feature.icon,
                                title: feature.localizedTitle,
                                description: feature.localizedDescription
                            )
                        }
                    } header: {
                        Text(verbatim: "Version \(version.version)")
                    }
                }
            }
            .navigationTitle(String(localized: "What's New"))
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

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(.tint)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.medium)
                Text(description)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

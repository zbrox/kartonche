//
//  NearbyNotificationsExplanationView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI

/// View that explains nearby card notifications feature and requests opt-in
struct NearbyNotificationsExplanationView: View {
    let onEnable: () -> Void
    let onNotNow: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "location.circle.fill")
                .font(.system(size: 56))
                .foregroundStyle(.blue)
                .padding(.top, 8)
            
            Text(String(localized: "Nearby Card Notifications"))
                .font(.title2)
                .fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 12) {
                Text(String(localized: "Never forget your loyalty card at the store"))
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(String(localized: "This helps you:"))
                        .fontWeight(.semibold)
                    
                    Label(String(localized: "Auto-show the right card"), systemImage: "sparkles")
                    Label(String(localized: "See cards when you're nearby"), systemImage: "mappin.and.ellipse")
                    Label(String(localized: "Find nearest card in widgets"), systemImage: "apps.iphone")
                }
                .font(.subheadline)
                
                Text(String(localized: "Respects iOS Focus modes and Do Not Disturb. Silent notifications only."))
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal)
            
            Spacer()
            
            VStack(spacing: 12) {
                Button {
                    onEnable()
                } label: {
                    Text(String(localized: "Enable Nearby Notifications"))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                
                Button {
                    onNotNow()
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

#Preview {
    NearbyNotificationsExplanationView(
        onEnable: { print("Enable") },
        onNotNow: { print("Not Now") }
    )
}

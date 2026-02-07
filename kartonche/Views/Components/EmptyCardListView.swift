//
//  EmptyCardListView.swift
//  kartonche
//
//  Created on 2026-02-07.
//

import SwiftUI

struct EmptyCardListView: View {
    let onAddCard: () -> Void
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            // Illustration using SF Symbols
            ZStack {
                Circle()
                    .fill(Color.accentColor.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "wallet.bifold.fill")
                    .font(.system(size: 48))
                    .foregroundStyle(.tint)
            }
            
            // Title and subtitle
            VStack(spacing: 12) {
                Text(String(localized: "Your cards, always ready"))
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text(String(localized: "Add your first loyalty card to get started"))
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }
            
            // Primary CTA
            Button {
                onAddCard()
            } label: {
                Label(String(localized: "Add Card"), systemImage: "plus")
                    .font(.headline)
                    .frame(minWidth: 160)
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.large)
            .accessibilityIdentifier("addFirstCardButton")
            
            Spacer()
            Spacer()
        }
        .padding()
    }
}

#Preview {
    EmptyCardListView {
        print("Add card tapped")
    }
}

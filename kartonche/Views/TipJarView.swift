//
//  TipJarView.swift
//  kartonche
//
//  Created on 2026-03-22.
//

import SwiftUI
import StoreKit

struct TipJarView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = TipStore()
    @State private var showingThankYou = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Text(String(localized: "Kartonche is free and open-source, and always will be. If you find it useful, a tip helps cover the annual Apple Developer fee. Tips don't unlock anything — they're purely voluntary.", comment: "Explanatory text in the tip jar sheet"))
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Section {
                    if store.isLoading {
                        HStack {
                            Spacer()
                            ProgressView()
                            Spacer()
                        }
                    } else if store.products.isEmpty {
                        Text(String(localized: "Unable to load products. Please try again later.", comment: "Error message when tip jar products fail to load"))
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(store.products, id: \.id) { product in
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(product.displayName)
                                        .font(.body)
                                    if !product.description.isEmpty {
                                        Text(product.description)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                }

                                Spacer()

                                Button {
                                    Task {
                                        let success = await store.purchase(product)
                                        if success {
                                            showingThankYou = true
                                        }
                                    }
                                } label: {
                                    Text(product.displayPrice)
                                        .font(.subheadline)
                                        .fontWeight(.semibold)
                                }
                                .buttonStyle(.borderedProminent)
                                .buttonBorderShape(.capsule)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                }

                if let error = store.purchaseError {
                    Section {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                }
            }
            .navigationTitle(String(localized: "Support Development", comment: "Navigation title for the tip jar sheet"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(String(localized: "Done", comment: "Button to dismiss tip jar sheet")) {
                        dismiss()
                    }
                }
            }
            .task {
                await store.loadProducts()
            }
            .alert(
                String(localized: "Thank You!", comment: "Title of the thank-you alert after a successful tip"),
                isPresented: $showingThankYou
            ) {
                Button(String(localized: "OK", comment: "Dismiss button for thank-you alert")) { }
            } message: {
                Text(String(localized: "Your support means a lot and helps cover the cost of keeping Kartonche on the App Store. Thank you!", comment: "Thank-you message after a successful tip"))
            }
        }
    }
}

#Preview {
    TipJarView()
}

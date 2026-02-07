//
//  MerchantSelectionView.swift
//  kartonche
//
//  Created on 2026-02-05.
//

import SwiftUI

struct MerchantSelectionView: View {
    @State private var searchText = ""
    @Binding var isPresented: Bool
    
    let onSelect: (MerchantTemplate, ProgramTemplate?) -> Void
    
    private var filteredMerchants: [MerchantTemplate] {
        MerchantTemplate.search(searchText)
    }
    
    private var groupedMerchants: [MerchantCategory: [MerchantTemplate]] {
        Dictionary(grouping: filteredMerchants, by: \.category)
    }
    
    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        addCustomCard()
                    } label: {
                        Label("Add Card Manually", systemImage: "plus.circle.fill")
                            .font(.headline)
                    }
                    .accessibilityIdentifier("customCardButton")
                }
                .listRowBackground(Color.accentColor.opacity(0.1))
                
                ForEach(MerchantCategory.allCases, id: \.self) { category in
                    if let merchants = groupedMerchants[category], !merchants.isEmpty {
                        Section(category.displayName) {
                            ForEach(merchants) { merchant in
                                Button {
                                    selectMerchant(merchant)
                                } label: {
                                    MerchantRowView(merchant: merchant)
                                }
                                .accessibilityIdentifier("merchant_\(merchant.id)")
                            }
                        }
                    }
                }
            }
            .searchable(
                text: $searchText,
                prompt: Text("Search Merchant")
            )
            .navigationTitle("Select Merchant")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        isPresented = false
                    }
                    .accessibilityIdentifier("cancelButton")
                }
            }
        }
    }
    
    private func selectMerchant(_ merchant: MerchantTemplate) {
        onSelect(merchant, merchant.programs.first)
    }
    
    private func addCustomCard() {
        onSelect(
            MerchantTemplate(
                id: "",
                name: "",
                otherNames: [],
                category: .retail,
                website: nil,
                suggestedColor: nil,
                secondaryColor: nil,
                programs: []
            ),
            nil
        )
    }
}

#Preview {
    MerchantSelectionView(isPresented: .constant(true)) { merchant, program in
        print("Selected: \(merchant.name)")
    }
}

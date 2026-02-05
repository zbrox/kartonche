//
//  MerchantSelectionView.swift
//  kartonche
//
//  Created on 2026-02-05.
//

import SwiftUI

struct MerchantSelectionView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
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
                ForEach(MerchantCategory.allCases, id: \.self) { category in
                    if let merchants = groupedMerchants[category], !merchants.isEmpty {
                        Section(category.displayName) {
                            ForEach(merchants) { merchant in
                                Button {
                                    selectMerchant(merchant)
                                } label: {
                                    MerchantRowView(merchant: merchant)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
                
                Section {
                    Button {
                        addCustomCard()
                    } label: {
                        Label("Добави карта ръчно", systemImage: "plus.circle")
                    }
                }
            }
            .searchable(
                text: $searchText,
                prompt: Text("Търсене на магазин")
            )
            .navigationTitle("Избор на магазин")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Отказ") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func selectMerchant(_ merchant: MerchantTemplate) {
        if merchant.programs.count == 1 {
            onSelect(merchant, merchant.programs.first)
            dismiss()
        } else {
            // TODO: Show program selection sheet for multi-program merchants
            // For now, just use first program
            onSelect(merchant, merchant.programs.first)
            dismiss()
        }
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
        dismiss()
    }
}

#Preview {
    MerchantSelectionView { merchant, program in
        print("Selected: \(merchant.name)")
    }
}

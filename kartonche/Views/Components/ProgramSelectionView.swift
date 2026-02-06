//
//  ProgramSelectionView.swift
//  kartonche
//
//  Created on 2026-02-06.
//

import SwiftUI

struct ProgramSelectionView: View {
    let merchant: MerchantTemplate
    @Binding var isPresented: Bool
    let onSelect: (ProgramTemplate) -> Void
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(merchant.programs) { program in
                    Button {
                        onSelect(program)
                    } label: {
                        HStack(spacing: 12) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(program.name ?? merchant.name)
                                    .font(.body)
                                    .foregroundColor(.primary)
                            }
                            
                            Spacer()
                            
                            Text(program.barcodeType.displayName)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(Color.secondary.opacity(0.2))
                                .cornerRadius(4)
                                .accessibilityLabel(Text("Barcode type"))
                        }
                        .padding(.vertical, 4)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("\(program.name ?? merchant.name), \(program.barcodeType.displayName)")
                }
            }
            .navigationTitle(String(localized: "Choose Program"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button(String(localized: "Cancel")) {
                        isPresented = false
                    }
                }
            }
        }
    }
}

#Preview {
    ProgramSelectionView(
        merchant: MerchantTemplate(
            id: "bg.kaufland",
            name: "Kaufland",
            otherNames: ["Кауфланд"],
            category: .grocery,
            website: "https://www.kaufland.bg",
            suggestedColor: "#FF0000",
            secondaryColor: "#FFFFFF",
            programs: [
                ProgramTemplate(id: "regular", name: "Kaufland Card", barcodeType: .ean13),
                ProgramTemplate(id: "plus", name: "Kaufland Card Plus", barcodeType: .ean13)
            ]
        ),
        isPresented: .constant(true)
    ) { program in
        print("Selected: \(program.name ?? "Unknown")")
    }
}

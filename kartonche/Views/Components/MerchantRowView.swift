//
//  MerchantRowView.swift
//  kartonche
//
//  Created on 2026-02-05.
//

import SwiftUI

struct MerchantRowView: View {
    let merchant: MerchantTemplate
    
    var body: some View {
        HStack(spacing: 12) {
            // Colored circle with initials
            ZStack {
                Circle()
                    .fill(Color(hex: merchant.suggestedColor) ?? Color.gray)
                    .frame(width: 44, height: 44)
                
                Text(merchant.initials)
                    .font(.body.weight(.bold))
                    .foregroundColor(Color(hex: merchant.secondaryColor) ?? Color.white)
            }
            .accessibilityHidden(true)
            
            // Merchant info
            VStack(alignment: .leading, spacing: 4) {
                Text(merchant.displayName)
                    .font(.body)
                    .foregroundColor(.primary)
                
                if let website = merchant.website {
                    Text(website.replacingOccurrences(of: "https://", with: "")
                                .replacingOccurrences(of: "www.", with: ""))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Barcode type badge
            if merchant.hasSingleProgram, let program = merchant.programs.first {
                // Single program - show barcode type
                Text(program.barcodeType.displayName)
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            } else if !merchant.programs.isEmpty {
                // Multiple programs - show count
                Text("\(merchant.programs.count) \(String(localized: "Programs"))")
                    .font(.caption)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.secondary.opacity(0.2))
                    .cornerRadius(4)
            }
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel(accessibilityMerchantLabel)
    }
    
    private var accessibilityMerchantLabel: String {
        var label = merchant.displayName
        if merchant.hasSingleProgram, let program = merchant.programs.first {
            label += ", " + program.barcodeType.displayName
        } else if merchant.programs.count > 1 {
            label += ", \(merchant.programs.count) " + String(localized: "Programs")
        }
        return label
    }
}

// Helper extension for hex color support
extension Color {
    init?(hex: String?) {
        guard let hex = hex else { return nil }
        let hexSanitized = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hexSanitized.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            return nil
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview {
    List {
        MerchantRowView(merchant: MerchantTemplate(
            id: "bg.billa",
            name: "BILLA",
            otherNames: ["Била"],
            category: .grocery,
            website: "https://www.billa.bg",
            suggestedColor: "#FFED00",
            secondaryColor: "#000000",
            programs: [ProgramTemplate(id: "bg.billa", name: nil, barcodeType: .ean13)]
        ))
        
        MerchantRowView(merchant: MerchantTemplate(
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
        ))
    }
}

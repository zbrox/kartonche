//
//  Color+Extensions.swift
//  kartonche
//
//  Created on 8.2.2026.
//

import SwiftUI
import UIKit

extension Color {
    /// Initialize Color from hex string (supports #RGB, #RRGGBB, #AARRGGBB)
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
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// Convert Color to hex string (#RRGGBB format)
    func toHex() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }
        
        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)
        
        return String(format: "#%02X%02X%02X", r, g, b)
    }
    
    /// Returns "rgb(R,G,B)" string for Apple Wallet pass.json
    func toPassRGB() -> String? {
        guard let components = UIColor(self).cgColor.components else { return nil }

        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)

        return "rgb(\(r),\(g),\(b))"
    }

    /// Returns a contrasting text color (white or black) based on the background color's luminance
    func contrastingTextColor() -> Color {
        let uiColor = UIColor(self)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        // Calculate relative luminance using sRGB coefficients
        let luminance = 0.299 * red + 0.587 * green + 0.114 * blue
        
        // Return white for dark backgrounds, black for light backgrounds
        return luminance > 0.5 ? .black : .white
    }
}

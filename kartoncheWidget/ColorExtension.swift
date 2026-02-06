//
//  ColorExtension.swift
//  kartoncheWidget
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import SwiftUI
import UIKit

extension Color {
    init?(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }
        
        let length = hexSanitized.count
        let r, g, b, a: Double
        
        if length == 6 {
            r = Double((rgb & 0xFF0000) >> 16) / 255.0
            g = Double((rgb & 0x00FF00) >> 8) / 255.0
            b = Double(rgb & 0x0000FF) / 255.0
            a = 1.0
        } else if length == 8 {
            r = Double((rgb & 0xFF000000) >> 24) / 255.0
            g = Double((rgb & 0x00FF0000) >> 16) / 255.0
            b = Double((rgb & 0x0000FF00) >> 8) / 255.0
            a = Double(rgb & 0x000000FF) / 255.0
        } else {
            return nil
        }
        
        self.init(.sRGB, red: r, green: g, blue: b, opacity: a)
    }
    
    /// Returns a contrasting text color (black or white) based on the background color's luminance
    var contrastingTextColor: Color {
        guard let components = UIColor(self).cgColor.components else {
            return .white
        }
        
        let r = components[0]
        let g = components.count > 1 ? components[1] : components[0]
        let b = components.count > 2 ? components[2] : components[0]
        
        // Calculate relative luminance using WCAG formula
        let luminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
        
        // Use black text for bright backgrounds, white text for dark backgrounds
        return luminance > 0.6 ? .black : .white
    }
}

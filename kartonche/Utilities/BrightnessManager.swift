//
//  BrightnessManager.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import UIKit

/// Manages screen brightness for optimal barcode scanning
@MainActor
final class BrightnessManager {
    
    private var originalBrightness: CGFloat?
    
    /// Increase screen brightness to maximum for barcode display
    func increaseForBarcode() {
        guard originalBrightness == nil else { return }
        
        originalBrightness = UIScreen.main.brightness
        UIScreen.main.brightness = 1.0
    }
    
    /// Restore original screen brightness
    func restore() {
        guard let original = originalBrightness else { return }
        
        UIScreen.main.brightness = original
        originalBrightness = nil
    }
}

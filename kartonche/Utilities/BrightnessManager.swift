//
//  BrightnessManager.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import UIKit
import Combine

/// Manages screen brightness for optimal barcode scanning
@MainActor
final class BrightnessManager: ObservableObject {
    
    private var originalBrightness: CGFloat?
    private weak var screen: UIScreen?
    
    /// Increase screen brightness to maximum for barcode display
    func increaseForBarcode(screen: UIScreen?) {
        guard originalBrightness == nil else { return }
        guard let screen = screen else { return }
        
        self.screen = screen
        originalBrightness = screen.brightness
        screen.brightness = 1.0
    }
    
    /// Restore original screen brightness
    func restore() {
        guard let original = originalBrightness else { return }
        guard let screen = screen else { return }
        
        screen.brightness = original
        originalBrightness = nil
        self.screen = nil
    }
}

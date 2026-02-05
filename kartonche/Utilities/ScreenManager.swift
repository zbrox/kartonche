//
//  ScreenManager.swift
//  kartonche
//
//  Created on 5.2.2026.
//

import UIKit

/// Manages screen idle timer to prevent sleep during barcode display
@MainActor
final class ScreenManager {
    
    private var wasIdleTimerDisabled: Bool = false
    
    /// Prevent screen from sleeping during barcode display
    func preventSleep() {
        wasIdleTimerDisabled = UIApplication.shared.isIdleTimerDisabled
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    /// Restore original idle timer state
    func restoreIdleTimer() {
        UIApplication.shared.isIdleTimerDisabled = wasIdleTimerDisabled
    }
}

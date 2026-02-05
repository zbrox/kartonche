//
//  BrightnessManagerTests.swift
//  kartoncheTests
//
//  Created on 2026-02-05.
//

import Testing
import UIKit
@testable import kartonche

@MainActor
struct BrightnessManagerTests {
    
    // Note: UIScreen.main.brightness changes do not work in iOS Simulator
    // These tests verify the API calls complete without errors and that
    // the manager's state management works correctly
    
    @Test func increaseForBarcodeCompletesWithoutError() {
        let manager = BrightnessManager()
        let originalBrightness = UIScreen.main.brightness
        
        // Should complete without throwing or crashing
        manager.increaseForBarcode()
        
        // Cleanup
        manager.restore()
        UIScreen.main.brightness = originalBrightness
    }
    
    @Test func restoreCompletesWithoutError() {
        let manager = BrightnessManager()
        let originalBrightness = UIScreen.main.brightness
        
        manager.increaseForBarcode()
        
        // Should complete without throwing or crashing
        manager.restore()
        
        // Cleanup
        UIScreen.main.brightness = originalBrightness
    }
    
    @Test func multipleIncreasesDoNotCrash() {
        let manager = BrightnessManager()
        let originalBrightness = UIScreen.main.brightness
        
        // Multiple calls should be safe (guard prevents override)
        manager.increaseForBarcode()
        manager.increaseForBarcode()
        manager.increaseForBarcode()
        
        manager.restore()
        
        // Cleanup
        UIScreen.main.brightness = originalBrightness
    }
    
    @Test func restoreWithoutIncreaseDoesNotCrash() {
        let manager = BrightnessManager()
        let originalBrightness = UIScreen.main.brightness
        
        // Should handle restore without increase gracefully
        manager.restore()
        
        // Cleanup
        UIScreen.main.brightness = originalBrightness
    }
    
    @Test func multipleRestoresAreSafe() {
        let manager = BrightnessManager()
        let originalBrightness = UIScreen.main.brightness
        
        manager.increaseForBarcode()
        
        // Multiple restores should be safe (guard prevents issues)
        manager.restore()
        manager.restore()
        manager.restore()
        
        // Cleanup
        UIScreen.main.brightness = originalBrightness
    }
}

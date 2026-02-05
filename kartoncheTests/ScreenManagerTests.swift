//
//  ScreenManagerTests.swift
//  kartoncheTests
//
//  Created on 2026-02-05.
//

import Testing
import UIKit
@testable import kartonche

@MainActor
struct ScreenManagerTests {
    
    @Test func preventSleepDisablesIdleTimer() {
        let manager = ScreenManager()
        let originalState = UIApplication.shared.isIdleTimerDisabled
        
        manager.preventSleep()
        
        #expect(UIApplication.shared.isIdleTimerDisabled == true, "Idle timer should be disabled")
        
        // Cleanup
        UIApplication.shared.isIdleTimerDisabled = originalState
    }
    
    @Test func restoreIdleTimerRestoresOriginalState() {
        let manager = ScreenManager()
        let originalState = UIApplication.shared.isIdleTimerDisabled
        
        // Set to false initially
        UIApplication.shared.isIdleTimerDisabled = false
        
        manager.preventSleep()
        #expect(UIApplication.shared.isIdleTimerDisabled == true)
        
        manager.restoreIdleTimer()
        #expect(UIApplication.shared.isIdleTimerDisabled == false, "Should restore to false")
        
        // Cleanup
        UIApplication.shared.isIdleTimerDisabled = originalState
    }
    
    @Test func restoreIdleTimerWithPreviouslyDisabled() {
        let manager = ScreenManager()
        let originalState = UIApplication.shared.isIdleTimerDisabled
        
        // Set to true initially (was already disabled)
        UIApplication.shared.isIdleTimerDisabled = true
        
        manager.preventSleep()
        #expect(UIApplication.shared.isIdleTimerDisabled == true)
        
        manager.restoreIdleTimer()
        #expect(UIApplication.shared.isIdleTimerDisabled == true, "Should restore to true")
        
        // Cleanup
        UIApplication.shared.isIdleTimerDisabled = originalState
    }
}

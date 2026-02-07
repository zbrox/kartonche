//
//  SharedDataManager.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import Foundation
import SwiftData

enum SharedDataManager {
    static let appGroupIdentifier = "group.com.zbrox.kartonche"
    
    private static var sharedUserDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }
    
    // MARK: - Last Known Location
    
    static func saveLastKnownLocation(latitude: Double, longitude: Double) {
        sharedUserDefaults?.set(latitude, forKey: "lastKnownLatitude")
        sharedUserDefaults?.set(longitude, forKey: "lastKnownLongitude")
        sharedUserDefaults?.set(Date(), forKey: "lastKnownLocationDate")
    }
    
    static func getLastKnownLocation() -> (latitude: Double, longitude: Double)? {
        guard let defaults = sharedUserDefaults,
              let lastUpdate = defaults.object(forKey: "lastKnownLocationDate") as? Date else {
            return nil
        }
        
        // Only use location if it's less than 1 hour old
        let hourAgo = Date().addingTimeInterval(-3600)
        guard lastUpdate > hourAgo else {
            return nil
        }
        
        let latitude = defaults.double(forKey: "lastKnownLatitude")
        let longitude = defaults.double(forKey: "lastKnownLongitude")
        
        guard latitude != 0 && longitude != 0 else {
            return nil
        }
        
        return (latitude, longitude)
    }
    
    // MARK: - App Launch Tracking
    
    static func incrementAppLaunchCount() {
        guard let defaults = sharedUserDefaults else { return }
        let count = defaults.integer(forKey: "appLaunchCount")
        defaults.set(count + 1, forKey: "appLaunchCount")
    }
    
    static func getAppLaunchCount() -> Int {
        sharedUserDefaults?.integer(forKey: "appLaunchCount") ?? 0
    }
    
    // MARK: - Always Permission Prompt Tracking
    
    static func hasShownAlwaysPrompt() -> Bool {
        sharedUserDefaults?.bool(forKey: "hasShownAlwaysPermissionPrompt") ?? false
    }
    
    static func markAlwaysPromptShown() {
        sharedUserDefaults?.set(true, forKey: "hasShownAlwaysPermissionPrompt")
    }
    
    static func hasDismissedAlwaysBanner() -> Bool {
        sharedUserDefaults?.bool(forKey: "hasDismissedAlwaysBanner") ?? false
    }
    
    static func markAlwaysBannerDismissed() {
        sharedUserDefaults?.set(true, forKey: "hasDismissedAlwaysBanner")
    }
    
    // MARK: - Model Container
    
    static func createSharedModelContainer() -> ModelContainer {
        let schema = Schema([
            LoyaltyCard.self,
            CardLocation.self,
        ])
        
        guard let sharedContainer = FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: appGroupIdentifier
        ) else {
            fatalError("Failed to get shared container URL for \(appGroupIdentifier)")
        }
        
        let storeURL = sharedContainer.appendingPathComponent("kartonche.store")
        let modelConfiguration = ModelConfiguration(
            url: storeURL,
            cloudKitDatabase: .none
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
    
    static func fetchAllCards() -> [LoyaltyCard] {
        let container = createSharedModelContainer()
        let context = ModelContext(container)
        
        let descriptor = FetchDescriptor<LoyaltyCard>(
            sortBy: [SortDescriptor(\.name)]
        )
        
        do {
            return try context.fetch(descriptor)
        } catch {
            print("Failed to fetch cards: \(error)")
            return []
        }
    }
    
    static func fetchCard(id: UUID) -> LoyaltyCard? {
        let container = createSharedModelContainer()
        let context = ModelContext(container)
        
        let predicate = #Predicate<LoyaltyCard> { card in
            card.id == id
        }
        
        let descriptor = FetchDescriptor<LoyaltyCard>(predicate: predicate)
        
        do {
            let results = try context.fetch(descriptor)
            return results.first
        } catch {
            print("Failed to fetch card: \(error)")
            return nil
        }
    }
}

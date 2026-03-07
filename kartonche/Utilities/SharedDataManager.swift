//
//  SharedDataManager.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-06.
//

import Foundation
import SwiftData
import CloudKit

enum SharedDataManager {
    static let appGroupIdentifier = "group.com.zbrox.kartonche.app"
    static let cloudContainerIdentifier = "iCloud.com.zbrox.kartonche.app"
    static let sharedModelContainer: ModelContainer = createSharedModelContainer()
    
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

    // MARK: - Sync Status

    static let lastSyncCheckDateKey = "lastSyncCheckDate"

    static func saveLastSyncCheckDate(_ date: Date) {
        sharedUserDefaults?.set(date, forKey: lastSyncCheckDateKey)
    }

    static func getLastSyncCheckDate() -> Date? {
        sharedUserDefaults?.object(forKey: lastSyncCheckDateKey) as? Date
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
            cloudKitDatabase: resolveCloudKitDatabase()
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    static func cloudKitDatabase(for accountStatus: CKAccountStatus) -> ModelConfiguration.CloudKitDatabase {
        switch accountStatus {
        case .available:
            return .automatic
        case .noAccount, .couldNotDetermine, .restricted, .temporarilyUnavailable:
            return .none
        @unknown default:
            return .none
        }
    }

    private static func resolveCloudKitDatabase() -> ModelConfiguration.CloudKitDatabase {
        guard let accountStatus = fetchCloudAccountStatus(timeout: 1.5) else {
            return .none
        }
        return cloudKitDatabase(for: accountStatus)
    }

    private static func fetchCloudAccountStatus(timeout: TimeInterval) -> CKAccountStatus? {
        let semaphore = DispatchSemaphore(value: 0)
        nonisolated(unsafe) var status: CKAccountStatus?

        CKContainer(identifier: cloudContainerIdentifier).accountStatus { accountStatus, _ in
            status = accountStatus
            semaphore.signal()
        }

        let waitResult = semaphore.wait(timeout: .now() + timeout)
        guard waitResult == .success else {
            return nil
        }

        return status
    }
    
    static func fetchAllCards() -> [LoyaltyCard] {
        let context = ModelContext(sharedModelContainer)
        
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
        let context = ModelContext(sharedModelContainer)
        
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

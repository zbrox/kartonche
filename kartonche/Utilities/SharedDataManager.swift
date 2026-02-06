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

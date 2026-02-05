//
//  kartoncheApp.swift
//  kartonche
//
//  Created by Rostislav Raykov on 2026-02-04.
//

import SwiftUI
import SwiftData

@main
struct kartoncheApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LoyaltyCard.self,
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .none
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            CardListView()
        }
        .modelContainer(sharedModelContainer)
    }
}

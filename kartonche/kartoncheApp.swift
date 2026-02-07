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
    var sharedModelContainer: ModelContainer = SharedDataManager.createSharedModelContainer()
    @StateObject private var locationManager = LocationManager()

    var body: some Scene {
        WindowGroup {
            CardListView()
                .onAppear {
                    // Request location on app launch to populate shared storage for widgets
                    // Only if we have cards with locations
                    if hasCardsWithLocations() {
                        locationManager.requestLocation()
                    }
                }
                .environmentObject(locationManager)
        }
        .modelContainer(sharedModelContainer)
        .handlesExternalEvents(matching: ["*"])
    }
    
    private func hasCardsWithLocations() -> Bool {
        let cards = SharedDataManager.fetchAllCards()
        return cards.contains(where: { !$0.locations.isEmpty })
    }
}

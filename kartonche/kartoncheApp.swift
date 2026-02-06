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

    var body: some Scene {
        WindowGroup {
            CardListView()
        }
        .modelContainer(sharedModelContainer)
        .handlesExternalEvents(matching: ["*"])
    }
}

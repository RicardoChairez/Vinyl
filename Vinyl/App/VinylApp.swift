//
//  VinylApp.swift
//  Vinyl
//
//  Created by Chip Chairez on 2/27/25.
//

import SwiftUI
import SwiftData

@main
struct VinylApp: App {
    var sharedModelContainer: ModelContainer
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
    
    init() {
        let schema = Schema([
            Media.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            sharedModelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            let fetchedCollections = try sharedModelContainer.mainContext.fetch(FetchDescriptor<Media>())
            if let previousCollections = fetchedCollections.first {

            } else {
//                let newCollections = Collections(ownedCollection: [], wantedCollection: [])
//                sharedModelContainer.mainContext.insert(newCollections)
            }
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
        
    }
}

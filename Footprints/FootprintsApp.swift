//
//  FootprintsApp.swift
//  Footprints
//
//  Created by Collin Palmer on 3/22/24.
//

import SwiftUI
import SwiftData
import GRDB

private struct SqliteEnvironmentKey: EnvironmentKey {
    static let defaultValue: DatabaseQueue = try! .default
}

extension EnvironmentValues {
    var databaseQueue: DatabaseQueue {
        get { self[SqliteEnvironmentKey.self] }
        set { self[SqliteEnvironmentKey.self] = newValue }
    }
}

@main
struct FootprintsApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
        .environment(\.databaseQueue, appDelegate.dbQueue)
    }
}

//
//  GRDBExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 3/24/24.
//

import Foundation
import GRDB

extension DatabaseQueue {
    static var dbURL: URL {
        get throws {
            let dbDir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: Bundle.main.bundleIdentifier!)
            try FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
            let dbURL = dbDir.appending(path: "db.sqlite")
            
            return dbURL
        }
    }
    
    static var `default`: DatabaseQueue {
        get throws {
            try DatabaseQueue(path: try dbURL.path)
        }
    }
    
    var url: URL {
        URL(filePath: self.path)
    }
    
    static func createTemporaryDBQueue() throws -> DatabaseQueue {
        let tmpDBURL = FileManager.default.temporaryDirectory.appending(path: "\(UUID().uuidString).sqlite")
        let dbQueue = try DatabaseQueue(path: tmpDBURL.path)
        
        try dbQueue.setupFootprintsSchema()
        try dbQueue.applyFootprintsMigrations()
        
        return dbQueue
    }
    
    func applyFootprintsMigrations() throws {
        var migrator = DatabaseMigrator()
        // This was already added in the initial schema... so it will cause a crash attempting to add an existing column.
        /*
        migrator.registerMigration("Add fiveKTime column to sessionModel table.") { db in
            try db.alter(table: "sessionModel") { table in
                table.add(column: "fiveKTime", .double)
            }
        }
         */
        
        migrator.registerMigration("Add tempFahrenheit column to sessionModel table.") { db in
            try db.alter(table: "sessionModel") { table in
                table.add(column: "tempFahrenheit", .integer)
            }
        }
        
        try migrator.migrate(self)
    }
    
    func setupFootprintsSchema() throws {
        try self.write { db in
            try db.create(table: "gpsLocationModel", options: .ifNotExists) { table in
                table.primaryKey("id", .text)
                table.column("sessionId", .text)
                table.column("latitude", .double)
                table.column("longitude", .double)
                table.column("altitude", .double)
                table.column("timestamp", .double)
            }
            
            try db.create(table: "sessionModel", options: .ifNotExists) { table in
                table.primaryKey("id", .text)
                table.column("startTimestamp", .double)
                table.column("endTimestamp", .double)
                table.column("count", .integer)
                table.column("totalDistance", .double)
            }
            
            try db.create(table: "deviceAccelerationModel", options: .ifNotExists) { table in
                table.primaryKey("id", .text)
                table.column("sessionId", .text)
                table.column("timestamp", .double)
                table.column("x", .double)
                table.column("y", .double)
                table.column("z", .double)
            }
        }
    }
}

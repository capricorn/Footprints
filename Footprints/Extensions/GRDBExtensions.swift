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
        
        return dbQueue
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
            }
        }
    }
}

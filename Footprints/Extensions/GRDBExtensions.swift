//
//  GRDBExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 3/24/24.
//

import Foundation
import GRDB

extension DatabaseQueue {
    static var `default`: DatabaseQueue {
        get throws {
            let dbDir = try FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            .appending(path: Bundle.main.bundleIdentifier!)
            
            try FileManager.default.createDirectory(at: dbDir, withIntermediateDirectories: true)
            let dbURL = dbDir.appending(path: "db.sqlite")
        
            return try DatabaseQueue(path: dbURL.path)
        }
    }
}

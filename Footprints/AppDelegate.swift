//
//  AppDelegate.swift
//  Footprints
//
//  Created by Collin Palmer on 3/24/24.
//

import Foundation
import UIKit
import GRDB

class AppDelegate: NSObject, UIApplicationDelegate {
    var dbQueue: DatabaseQueue!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        dbQueue = try! .default
        
        try! dbQueue.write { db in
            try! db.create(table: "GPSLocation", options: .ifNotExists) { table in
                table.primaryKey("id", .text)
                table.column("latitude", .double)
                table.column("longitude", .double)
                table.column("altitude", .double)
                table.column("timestamp", .double)
            }
        }
        
        return true
    }
}



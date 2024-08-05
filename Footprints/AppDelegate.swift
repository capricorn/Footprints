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
        try! dbQueue.setupFootprintsSchema()
        // How to determine if a migration is needed..?
        try! dbQueue.applyFootprintsMigrations()
        
        return true
    }
}



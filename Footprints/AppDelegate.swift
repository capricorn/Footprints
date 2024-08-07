//
//  AppDelegate.swift
//  Footprints
//
//  Created by Collin Palmer on 3/24/24.
//

import Foundation
import UIKit
import GRDB
import BackgroundTasks
import ActivityKit

private extension Data {
    var hexDescription: String {
        return reduce("") {$0 + String(format: "%02x", $1)}
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    var dbQueue: DatabaseQueue!
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        dbQueue = try! .default
        try! dbQueue.setupFootprintsSchema()
        // How to determine if a migration is needed..?
        try! dbQueue.applyFootprintsMigrations()
        
        UIApplication.shared.registerForRemoteNotifications()
        
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // TODO: Pass this to your server (what is it..?)
        // Should be passed as data in a post request presumably?
        print("Device token: \(deviceToken.hexDescription)")
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: any Error) {
        print("Failed to register for remote notifications: \(error)")
    }
    
    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable : Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        print("\(Date.now) got notification! \(userInfo)")
        
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo)
            let notification = try JSONDecoder().decode(APNLiveActivityNotification.self, from: data)
            print("Notification: \(notification)")
            guard let activity = Activity<FootprintsLiveActivityAttributes>.activities.first else {
                print("No live activity found.")
                return
            }
            
            Task {
                // TODO: Should run on an actor
                
                do {
                    let session = try await dbQueue.read { db in
                        try SessionModel.find(db, id: notification.sessionId)
                    }
                    
                    await activity.update(using: .init(session: session))
                } catch {
                    print("Failed to update live activity state: \(error)")
                }
            }
        } catch {
            print("Received notification was not a live activity update.")
        }
        
        completionHandler(.noData)
    }
}



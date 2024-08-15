//
//  WindowSceneDelegate.swift
//  Footprints
//
//  Created by Collin Palmer on 8/14/24.
//

import Foundation
import UIKit
import Combine

@MainActor
class WindowSceneDelegate: NSObject, UIWindowSceneDelegate {
    private var quickActionCancellable: AnyCancellable?
    
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        if shortcutItem.type == QuickAction.record.rawValue {
            QuickActionPublisherEnvironmentKey.quickActionSubject.send(.record)
            return true
        } else {
            return false
        }
    }
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        if let shortcut = connectionOptions.shortcutItem, shortcut.type == QuickAction.record.rawValue {
            quickActionCancellable = Just(NotificationCenter.default.publisher(for: LoggerViewModel.readyNotification.name)).sink { _ in
                QuickActionPublisherEnvironmentKey.quickActionSubject.send(.record)
            }
        }
    }
}

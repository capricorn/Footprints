//
//  WindowSceneDelegate.swift
//  Footprints
//
//  Created by Collin Palmer on 8/14/24.
//

import Foundation
import UIKit

class WindowSceneDelegate: NSObject, UIWindowSceneDelegate {
    @MainActor
    func windowScene(_ windowScene: UIWindowScene, performActionFor shortcutItem: UIApplicationShortcutItem) async -> Bool {
        print("Quick action: \(shortcutItem.localizedTitle)")
        // TODO:
        return false
    }
}

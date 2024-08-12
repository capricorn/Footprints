//
//  EnvironmentExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 8/8/24.
//

import Foundation
import SwiftUI
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


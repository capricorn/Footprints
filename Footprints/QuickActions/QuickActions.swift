//
//  QuickActions.swift
//  Footprints
//
//  Created by Collin Palmer on 8/14/24.
//

import Foundation
import SwiftUI
import Combine

typealias QuickActionPublisher = AnyPublisher<QuickAction, Never>

// TODO: Generate from plist?
enum QuickAction: String {
    case record = "FootprintsRecord"
}

struct QuickActionPublisherEnvironmentKey: EnvironmentKey {
    static let quickActionSubject = PassthroughSubject<QuickAction, Never>()
    static let defaultValue: QuickActionPublisher = quickActionSubject.eraseToAnyPublisher()
}

extension EnvironmentValues {
    var quickActionPublisher: QuickActionPublisher {
        get { self[QuickActionPublisherEnvironmentKey.self] }
        set { self[QuickActionPublisherEnvironmentKey.self] = newValue }
    }
}

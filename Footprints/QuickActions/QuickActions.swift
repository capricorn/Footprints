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

enum QuickAction: String {
    case record = "Record"
}

struct QuickActionPublisherEnvironmentKey: EnvironmentKey {
    static let quickActionSubject = PassthroughSubject<QuickAction, Never>()
    static let defaultValue: QuickActionPublisher = quickActionSubject.eraseToAnyPublisher()//quickActionPublisher
}

extension EnvironmentValues {
    var quickActionPublisher: QuickActionPublisher {
        get { self[QuickActionPublisherEnvironmentKey.self] }
        set { self[QuickActionPublisherEnvironmentKey.self] = newValue }
    }
}

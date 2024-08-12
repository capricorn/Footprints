//
//  BundleExtensions.swift
//  Footprints
//
//  Created by Collin Palmer on 8/12/24.
//

import Foundation

extension Bundle {
    var version: String? {
        self.infoDictionary?["CFBundleShortVersionString"] as? String
    }
}

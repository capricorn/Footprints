//
//  CSVRepresentable.swift
//  Footprints
//
//  Created by Collin Palmer on 5/22/24.
//

import Foundation

protocol CSVRepresentable: Codable {
    static var headers: [String] { get }
}

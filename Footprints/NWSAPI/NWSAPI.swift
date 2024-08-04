//
//  NWSAPI.swift
//  Footprints
//
//  Created by Collin Palmer on 8/4/24.
//

import Foundation
import CoreLocation
import Combine

/// Docs: https://www.weather.gov/documentation/services-web-api
class NWSAPI {
    private struct Property: Codable {
        let forecast: String
    }
    
    private struct Points: Codable {
        let properties: Property
    }
    
    static let ENDPOINT = "https://api.weather.gov"
    
    private let gps: GPSProvider
    
    init(_ gps: GPSProvider = LocationDelegate()) {
        self.gps = gps
    }
    
    func fetchForecastEndpoint(loc: GPSLocation) async throws -> URL? {
        let req = URLRequest(url: URL(string: "\(NWSAPI.ENDPOINT)/points/\(loc.latitude),\(loc.longitude)")!)
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let points = try JSONDecoder().decode(Points.self, from: data)
        return URL(string: points.properties.forecast)
    }
}

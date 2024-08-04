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
        let forecastHourly: String
    }
    
    private struct Points: Codable {
        let properties: Property
    }
    
    private struct Period: Codable {
        let temperature: Int
    }
    
    private struct ForecastProperty: Codable {
        let periods: [Period]
    }
    
    private struct Forecast: Codable {
        let properties: ForecastProperty
    }
    
    
    static let ENDPOINT = "https://api.weather.gov"
    
    private let gps: GPSProvider
    
    init(_ gps: GPSProvider = LocationDelegate()) {
        self.gps = gps
    }
    
    // TODO: Maybe just have this return the 'points' data for the location?
    func fetchForecastEndpoint(loc: GPSLocation) async throws -> URL? {
        let req = URLRequest(url: URL(string: "\(NWSAPI.ENDPOINT)/points/\(loc.latitude),\(loc.longitude)")!)
        let (data, resp) = try await URLSession.shared.data(for: req)
        
        guard let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        let points = try JSONDecoder().decode(Points.self, from: data)
        return URL(string: points.properties.forecastHourly)
    }
    
    func fetchHourlyForecast(loc: GPSLocation) async throws -> Measurement<UnitTemperature>? {
        // TODO: Better error handling
        guard let forecastEndpointURL = try await fetchForecastEndpoint(loc: loc) else {
            return nil
        }
        
        let req = URLRequest(url: forecastEndpointURL)
        let (data, resp) = try await URLSession.shared.data(for: req)
        
         guard let httpResp = resp as? HTTPURLResponse, httpResp.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }       
        
        let forecast = try JSONDecoder().decode(Forecast.self, from: data)
        // TODO: Handle no existing properties
        return Measurement(value: Double(forecast.properties.periods[0].temperature), unit: .fahrenheit)
    }
}

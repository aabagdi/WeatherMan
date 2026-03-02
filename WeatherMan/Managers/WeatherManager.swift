//
//  WeatherManager.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/1/26.
//

import Foundation
import CoreLocation
import MapKit
import WeatherKit

enum WeatherManager {
  static func getWeather(for location: String) async throws -> CurrentWeather? {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = location
    request.resultTypes = .address
    
    let search = MKLocalSearch(request: request)
    let response = try await search.start()
    
    let centerCoords = response.boundingRegion.center
    
    let currentWeather = try await WeatherService.shared.weather(for: CLLocation(latitude: centerCoords.latitude, longitude: centerCoords.longitude)).currentWeather
    
    return currentWeather
  }
  
  private static func getTemp(for currentWeather: CurrentWeather?) -> Double {
    let temperature = currentWeather?.temperature.value ?? 0.0
    
    return temperature
  }
  
  static func getDailyForecast(for location: String) async throws -> Forecast<DayWeather> {
    let request = MKLocalSearch.Request()
    request.naturalLanguageQuery = location
    request.resultTypes = .address
    
    let search = MKLocalSearch(request: request)
    let response = try await search.start()
    
    let centerCoords = response.boundingRegion.center
    let clLocation = CLLocation(latitude: centerCoords.latitude, longitude: centerCoords.longitude)
    
    return try await WeatherService.shared.weather(for: clLocation, including: .daily)
  }
  
  static func convertTempUnitsAndConvertToReadable(tempUnit: TempUnit, currentWeather: CurrentWeather?) -> String {
    let celsiusTemp = getTemp(for: currentWeather)
    
    switch tempUnit {
    case .celsius:
      return String(Int(celsiusTemp.rounded()))
    case .fahrenheit:
      let fahrenheitTemp = ((celsiusTemp * 9 / 5) + 32).rounded()
      return String(Int(fahrenheitTemp))
    }
  }
}

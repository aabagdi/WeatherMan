//
//  PersistenceManager.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import Foundation

enum PersistenceActionType {
  case add
  case remove
}

enum PersistenceManager {
  static let defaults = UserDefaults.standard
  
  enum Keys {
    static let savedCities = "savedCities"
    static let tempUnit = "tempUnit"
  }
  
  static var tempUnit: TempUnit {
    get {
      let raw = defaults.string(forKey: Keys.tempUnit) ?? "fahrenheit"
      return raw == "celsius" ? .celsius : .fahrenheit
    }
    set {
      defaults.set(newValue == .celsius ? "celsius" : "fahrenheit", forKey: Keys.tempUnit)
    }
  }
  
  static func addCityToSaved(city: String) {
    var cities = retrieveSavedCities()
    guard !cities.contains(city) else { return }
    cities.append(city)
    storeSavedCities(cities: cities)
  }
  
  static func removeCityFromSaved(city: String) {
    var cities = retrieveSavedCities()
    cities.removeAll { $0 == city }
    storeSavedCities(cities: cities)
  }
  
  static func retrieveSavedCities() -> [String] {
    return defaults.stringArray(forKey: Keys.savedCities) ?? []
  }
  
  static private func storeSavedCities(cities: [String]) {
    defaults.set(cities, forKey: Keys.savedCities)
  }
}

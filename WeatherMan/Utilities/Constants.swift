//
//  Constants.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/1/26.
//

import Foundation

enum WMError: LocalizedError {
  case mapSearchError
  case weatherFetchError
  case locationError
  
  var errorDescription: String? {
    switch self {
    case .mapSearchError: "Unable to find location. Please try again."
    case .weatherFetchError: "Unable to fetch weather data. Please try again later."
    case .locationError: "Unable to determine your current location."
    }
  }
}

enum TempUnit {
  case celsius
  case fahrenheit
}

enum LocationSource {
  case currentLocation
  case custom(city: String)
}

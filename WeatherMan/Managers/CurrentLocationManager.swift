//
//  CurrentLocationManager.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import Foundation
import CoreLocation
import MapKit

class CurrentLocationManager: NSObject, CLLocationManagerDelegate {
  private var locationManager: CLLocationManager?
  private var authorizationContinuation: CheckedContinuation<Void, Never>?
  
  func getCurrentCity() async throws -> String? {
    locationManager = CLLocationManager()
    locationManager?.delegate = self
    
    if locationManager?.authorizationStatus == .notDetermined {
      await withCheckedContinuation { continuation in
        authorizationContinuation = continuation
        locationManager?.requestWhenInUseAuthorization()
      }
    }
    
    guard let locationManager else { return nil }
    
    switch locationManager.authorizationStatus {
    case .authorizedAlways, .authorizedWhenInUse:
      guard let currentLocation = locationManager.location else { return nil }
      guard let request = MKReverseGeocodingRequest(location: currentLocation) else { return nil }
      let mapItems = try await request.mapItems
      return mapItems.first?.addressRepresentations?.cityName
    case .restricted, .denied:
      return nil
    default:
      return nil
    }
  }
  
  func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
    if manager.authorizationStatus != .notDetermined {
      authorizationContinuation?.resume()
      authorizationContinuation = nil
    }
  }
}

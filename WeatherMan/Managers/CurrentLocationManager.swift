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
  private let locationManager = CLLocationManager()
  private var authorizationContinuation: CheckedContinuation<Void, Never>?
  private var lastKnownStatus: CLAuthorizationStatus?
  var onAuthorizationChanged: ((CLAuthorizationStatus) -> Void)?
  
  override init() {
    super.init()
    locationManager.delegate = self
  }
  
  func getCurrentCity() async throws -> String? {
    if locationManager.authorizationStatus == .notDetermined {
      await withCheckedContinuation { continuation in
        authorizationContinuation = continuation
        locationManager.requestWhenInUseAuthorization()
      }
    }
    
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
    let status = manager.authorizationStatus
    
    if status != .notDetermined {
      authorizationContinuation?.resume()
      authorizationContinuation = nil
    }
    
    defer { lastKnownStatus = status }
    
    guard let lastKnownStatus, status != lastKnownStatus else { return }
    onAuthorizationChanged?(status)
  }
}

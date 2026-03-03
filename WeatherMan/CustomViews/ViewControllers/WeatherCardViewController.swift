//
//  WeatherCardViewController.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 2/27/26.
//

import UIKit
import CoreLocation

class WeatherCardViewController: UIViewController {
  
  let locationManager = CurrentLocationManager()
  private lazy var locationSource = LocationSource.currentLocation
  
  let weatherCard = WeatherCardView()
  
  init(locationSource: LocationSource = .currentLocation) {
    super.init(nibName: nil, bundle: nil)
    self.locationSource = locationSource
  }
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    self.locationSource = .currentLocation
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    weatherCard.frame = CGRect(x: 20, y: 100, width: view.bounds.width - 40, height: 200)
    view.addSubview(weatherCard)
    
    Task {
      let city: String
      switch locationSource {
      case .currentLocation:
        city = (try? await locationManager.getCurrentCity()) ?? "Unknown"
      case .custom(let name):
        city = name
      }
      await configureWeatherCardView(currentCity: city)
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
  }
  
  private func configureWeatherCardView(currentCity: String) async {
    let currentWeather = try? await WeatherManager.getWeather(for: currentCity)
    weatherCard.currentWeather = currentWeather
    weatherCard.currentCity = currentCity
    weatherCard.configureUI()
  }
}

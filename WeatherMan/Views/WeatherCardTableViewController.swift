//
//  WeatherCardTableViewController.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import UIKit
import WeatherKit
import CoreLocation

class WeatherCardTableViewController: UITableViewController {
  
  private enum Section: Int, CaseIterable {
    case currentLocation = 0
    case savedCities = 1
  }
  
  private let locationManager = CurrentLocationManager()
  private var currentLocationWeather: CurrentWeather?
  private var currentCity: String?
  
  private var savedCities = [String]()
  private var savedCityWeathers = [String: CurrentWeather]()
  private var tempUnit: TempUnit = PersistenceManager.tempUnit
    
  override func viewDidLoad() {
    super.viewDidLoad()
    configureTableView()
    loadWeatherData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    refreshSavedCitiesIfNeeded()
  }
  
  private func configureTableView() {
    title = "WeatherMan"
    navigationItem.leftBarButtonItem = UIBarButtonItem(
      title: tempUnit == .fahrenheit ? "Imperial" : "Metric",
      primaryAction: UIAction { [weak self] _ in
        self?.toggleTempUnit()
      }
    )
    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .add, primaryAction: UIAction { [weak self] _ in
      self?.presentAddCitySheet()
    })
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "WeatherCardCell")
    tableView.separatorStyle = .none
    tableView.rowHeight = 220
  }
  
  private func toggleTempUnit() {
    tempUnit = tempUnit == .fahrenheit ? .celsius : .fahrenheit
    PersistenceManager.tempUnit = tempUnit
    navigationItem.leftBarButtonItem?.title = tempUnit == .fahrenheit ? "Imperial" : "Metric"
    tableView.reloadData()
  }
  
  private func presentAddCitySheet() {
    let addCityVC = AddCityViewController()
    addCityVC.modalPresentationStyle = .formSheet
    addCityVC.onDismiss = { [weak self] in
      self?.refreshSavedCitiesIfNeeded()
    }
    present(addCityVC, animated: true)
  }
    
  private func loadWeatherData() {
    savedCities = PersistenceManager.retrieveSavedCities()
    
    locationManager.onAuthorizationChanged = { [weak self] status in
      switch status {
      case .authorizedWhenInUse, .authorizedAlways:
        self?.fetchCurrentLocationWeather()
      case .denied, .restricted:
        self?.currentLocationWeather = nil
        self?.currentCity = nil
        self?.tableView.reloadSections(IndexSet(integer: Section.currentLocation.rawValue), with: .automatic)
        self?.presentWMAlert(title: "WeatherMan can't use location services", message: "Check location services permissions in settings")
      default:
        break
      }
    }
    
    fetchCurrentLocationWeather()
    fetchSavedCityWeathers()
  }
  
  private func fetchCurrentLocationWeather() {
    Task {
      do {
        let city = try await locationManager.getCurrentCity()
        currentCity = city ?? "Unknown"
      } catch {
        currentCity = "Unknown"
        presentWMAlert(for: .locationError)
      }
      
      do {
        currentLocationWeather = try await WeatherManager.getWeather(for: currentCity ?? "Unknown")
      } catch {
        presentWMAlert(for: .weatherFetchError)
      }
      
      tableView.reloadSections(IndexSet(integer: Section.currentLocation.rawValue), with: .automatic)
    }
  }
  
  private func fetchSavedCityWeathers() {
    for city in savedCities {
      Task {
        do {
          let weather = try await WeatherManager.getWeather(for: city)
          savedCityWeathers[city] = weather
        } catch {
          presentWMAlert(for: .weatherFetchError)
        }
        if let index = savedCities.firstIndex(of: city) {
          tableView.reloadRows(at: [IndexPath(row: index, section: Section.savedCities.rawValue)], with: .automatic)
        }
      }
    }
  }
  
  private func refreshSavedCitiesIfNeeded() {
    let previousCities = savedCities
    savedCities = PersistenceManager.retrieveSavedCities()
    if savedCities != previousCities {
      tableView.reloadSections(IndexSet(integer: Section.savedCities.rawValue), with: .automatic)
      fetchSavedCityWeathers()
    }
  }
    
  private func configureCell(_ cell: UITableViewCell, at indexPath: IndexPath) {
    cell.selectionStyle = .none
    cell.backgroundColor = .clear
    cell.contentView.subviews.forEach { $0.removeFromSuperview() }
    
    let weatherCard = makeWeatherCard(for: indexPath)
    weatherCard.translatesAutoresizingMaskIntoConstraints = false
    cell.contentView.addSubview(weatherCard)
    
    NSLayoutConstraint.activate([
      weatherCard.leadingAnchor.constraint(equalTo: cell.contentView.leadingAnchor, constant: 20),
      weatherCard.trailingAnchor.constraint(equalTo: cell.contentView.trailingAnchor, constant: -20),
      weatherCard.topAnchor.constraint(equalTo: cell.contentView.topAnchor, constant: 10),
      weatherCard.bottomAnchor.constraint(equalTo: cell.contentView.bottomAnchor, constant: -10),
    ])
  }
  
  private func makeWeatherCard(for indexPath: IndexPath) -> WeatherCardView {
    let weatherCard = WeatherCardView()
    weatherCard.tempUnit = tempUnit
    
    switch Section(rawValue: indexPath.section)! {
    case .currentLocation:
      weatherCard.currentWeather = currentLocationWeather
      weatherCard.currentCity = currentCity ?? "Current Location"
    case .savedCities:
      let city = savedCities[indexPath.row]
      weatherCard.currentWeather = savedCityWeathers[city]
      weatherCard.currentCity = city
    }
    
    weatherCard.configureUI()
    return weatherCard
  }
    
  private func deleteSavedCity(at indexPath: IndexPath) {
    let city = savedCities[indexPath.row]
    savedCities.remove(at: indexPath.row)
    savedCityWeathers.removeValue(forKey: city)
    PersistenceManager.removeCityFromSaved(city: city)
    tableView.deleteRows(at: [indexPath], with: .automatic)
  }
}

extension WeatherCardTableViewController {
  override func numberOfSections(in tableView: UITableView) -> Int {
    Section.allCases.count
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    switch Section(rawValue: section)! {
    case .currentLocation:
      return 1
    case .savedCities:
      return savedCities.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "WeatherCardCell", for: indexPath)
    configureCell(cell, at: indexPath)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    switch Section(rawValue: section)! {
    case .currentLocation:
      return "Current Location"
    case .savedCities:
      return savedCities.isEmpty ? nil : "Saved Cities"
    }
  }
}

extension WeatherCardTableViewController {
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let weather: CurrentWeather?
    let city: String
    
    switch Section(rawValue: indexPath.section)! {
    case .currentLocation:
      weather = currentLocationWeather
      city = currentCity ?? "Current Location"
    case .savedCities:
      let savedCity = savedCities[indexPath.row]
      weather = savedCityWeathers[savedCity]
      city = savedCity
    }
    
    guard let weather else { return }
    
    let detailVC = WeatherDetailViewController(weather: weather, city: city)
    let navController = UINavigationController(rootViewController: detailVC)
    present(navController, animated: true)
  }
  
  override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
    Section(rawValue: indexPath.section) == .savedCities
  }
  
  override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
    guard editingStyle == .delete, Section(rawValue: indexPath.section) == .savedCities else { return }
    deleteSavedCity(at: indexPath)
  }
}

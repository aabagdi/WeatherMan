//
//  WeatherDetailViewController.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import UIKit
import WeatherKit

class WeatherDetailViewController: UIViewController {
  
  private let weather: CurrentWeather
  private let city: String
  
  private let scrollView = UIScrollView()
  private let contentStack = UIStackView()
  private let forecastStack = UIStackView()
  
  init(weather: CurrentWeather, city: String) {
    self.weather = weather
    self.city = city
    super.init(nibName: nil, bundle: nil)
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    title = city
    navigationItem.rightBarButtonItem = UIBarButtonItem(systemItem: .close, primaryAction: UIAction { [weak self] _ in
      self?.dismiss(animated: true)
    })
    configureScrollView()
    buildContent()
    fetchDailyForecast()
  }
  
  private func configureScrollView() {
    scrollView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(scrollView)
    
    contentStack.axis = .vertical
    contentStack.spacing = 24
    contentStack.layoutMargins = UIEdgeInsets(top: 24, left: 20, bottom: 24, right: 20)
    contentStack.isLayoutMarginsRelativeArrangement = true
    contentStack.translatesAutoresizingMaskIntoConstraints = false
    scrollView.addSubview(contentStack)
    
    NSLayoutConstraint.activate([
      scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
      
      contentStack.topAnchor.constraint(equalTo: scrollView.topAnchor),
      contentStack.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
      contentStack.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
      contentStack.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
      contentStack.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
    ])
  }
  
  private func buildContent() {
    contentStack.addArrangedSubview(buildHeaderSection())
    contentStack.addArrangedSubview(buildDetailGrid())
  }
  
  private func buildHeaderSection() -> UIStackView {
    let headerStack = UIStackView()
    headerStack.axis = .vertical
    headerStack.alignment = .center
    headerStack.spacing = 8
    
    let symbolConfig = UIImage.SymbolConfiguration(pointSize: 64, weight: .regular)
    let iconView = UIImageView(image: UIImage(systemName: weather.symbolName, withConfiguration: symbolConfig))
    iconView.contentMode = .scaleAspectFit
    iconView.tintColor = .label
    
    let tempUnit = PersistenceManager.tempUnit
    let tempLabel = UILabel()
    let tempString = WeatherManager.convertTempUnitsAndConvertToReadable(tempUnit: tempUnit, currentWeather: weather)
    let unitSuffix = tempUnit == .fahrenheit ? "°F" : "°C"
    tempLabel.text = "\(tempString)\(unitSuffix)"
    tempLabel.font = .systemFont(ofSize: 48, weight: .bold)
    
    let conditionLabel = UILabel()
    conditionLabel.text = weather.condition.description.capitalized
    conditionLabel.font = .systemFont(ofSize: 20, weight: .medium)
    conditionLabel.textColor = .secondaryLabel
    
    headerStack.addArrangedSubview(iconView)
    headerStack.addArrangedSubview(tempLabel)
    headerStack.addArrangedSubview(conditionLabel)
    
    return headerStack
  }
  
  private func formatFeelsLike(unit: TempUnit) -> String {
    if unit == .fahrenheit {
      let feelsLikeF = ((weather.apparentTemperature.value * 9 / 5) + 32).rounded()
      return "\(Int(feelsLikeF))°F"
    } else {
      return "\(Int(weather.apparentTemperature.value.rounded()))°C"
    }
  }
  
  private func buildDetailGrid() -> UIStackView {
    let tempUnit = PersistenceManager.tempUnit
    
    let details: [(icon: String, title: String, value: String)] = [
      ("thermometer.medium", "Feels Like", formatFeelsLike(unit: tempUnit)),
      ("humidity.fill", "Humidity", "\(Int(weather.humidity * 100))%"),
      ("wind", "Wind", formatWind(weather.wind, unit: tempUnit)),
      ("eye.fill", "Visibility", formatVisibility(weather.visibility, unit: tempUnit)),
      ("gauge.with.dots.needle.bottom.50percent", "Pressure", formatPressure(weather.pressure, unit: tempUnit)),
      ("sun.max.fill", "UV Index", "\(weather.uvIndex.value) (\(weather.uvIndex.category.description))"),
      ("drop.degreesign.fill", "Dew Point", formatTemp(weather.dewPoint, unit: tempUnit)),
      ("cloud.fill", "Cloud Cover", "\(Int(weather.cloudCover * 100))%"),
    ]
    
    let gridStack = UIStackView()
    gridStack.axis = .vertical
    gridStack.spacing = 12
    
    for rowStart in stride(from: 0, to: details.count, by: 2) {
      let rowStack = UIStackView()
      rowStack.axis = .horizontal
      rowStack.distribution = .fillEqually
      rowStack.spacing = 12
      
      rowStack.addArrangedSubview(makeDetailCard(details[rowStart]))
      if rowStart + 1 < details.count {
        rowStack.addArrangedSubview(makeDetailCard(details[rowStart + 1]))
      } else {
        rowStack.addArrangedSubview(UIView())
      }
      
      gridStack.addArrangedSubview(rowStack)
    }
    
    return gridStack
  }
  
  private func makeDetailCard(_ detail: (icon: String, title: String, value: String)) -> UIView {
    let card = UIView()
    card.backgroundColor = .secondarySystemBackground
    card.layer.cornerRadius = 12
    card.layer.shadowColor = UIColor.black.cgColor
    card.layer.shadowRadius = 4
    card.layer.shadowOpacity = 0.12
    card.layer.shadowOffset = CGSize(width: 0, height: 10)
    card.clipsToBounds = false
    
    let stack = UIStackView()
    stack.axis = .vertical
    stack.spacing = 6
    stack.alignment = .leading
    stack.layoutMargins = UIEdgeInsets(top: 14, left: 14, bottom: 14, right: 14)
    stack.isLayoutMarginsRelativeArrangement = true
    stack.translatesAutoresizingMaskIntoConstraints = false
    
    let iconConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
    let iconView = UIImageView(image: UIImage(systemName: detail.icon, withConfiguration: iconConfig))
    iconView.tintColor = .secondaryLabel
    
    let titleLabel = UILabel()
    titleLabel.text = detail.title
    titleLabel.font = .systemFont(ofSize: 13, weight: .medium)
    titleLabel.textColor = .secondaryLabel
    
    let valueLabel = UILabel()
    valueLabel.text = detail.value
    valueLabel.font = .systemFont(ofSize: 20, weight: .semibold)
    valueLabel.adjustsFontSizeToFitWidth = true
    valueLabel.minimumScaleFactor = 0.7
    
    stack.addArrangedSubview(iconView)
    stack.addArrangedSubview(titleLabel)
    stack.addArrangedSubview(valueLabel)
    
    card.addSubview(stack)
    NSLayoutConstraint.activate([
      stack.topAnchor.constraint(equalTo: card.topAnchor),
      stack.leadingAnchor.constraint(equalTo: card.leadingAnchor),
      stack.trailingAnchor.constraint(equalTo: card.trailingAnchor),
      stack.bottomAnchor.constraint(equalTo: card.bottomAnchor),
    ])
    
    return card
  }
  
  private func formatWind(_ wind: Wind, unit: TempUnit) -> String {
    if unit == .fahrenheit {
      let mph = wind.speed.converted(to: .milesPerHour).value.rounded()
      return "\(Int(mph)) mph \(wind.compassDirection.abbreviation)"
    } else {
      let kmh = wind.speed.converted(to: .kilometersPerHour).value.rounded()
      return "\(Int(kmh)) km/h \(wind.compassDirection.abbreviation)"
    }
  }
  
  private func formatVisibility(_ visibility: Measurement<UnitLength>, unit: TempUnit) -> String {
    if unit == .fahrenheit {
      let miles = visibility.converted(to: .miles).value
      return String(format: "%.1f mi", miles)
    } else {
      let km = visibility.converted(to: .kilometers).value
      return String(format: "%.1f km", km)
    }
  }
  
  private func formatPressure(_ pressure: Measurement<UnitPressure>, unit: TempUnit) -> String {
    if unit == .fahrenheit {
      let inHg = pressure.converted(to: .inchesOfMercury).value
      return String(format: "%.2f inHg", inHg)
    } else {
      let hPa = pressure.converted(to: .hectopascals).value
      return String(format: "%.0f hPa", hPa)
    }
  }
  
  private func formatTemp(_ temp: Measurement<UnitTemperature>, unit: TempUnit) -> String {
    if unit == .fahrenheit {
      let f = temp.converted(to: .fahrenheit).value.rounded()
      return "\(Int(f))°F"
    } else {
      let c = temp.converted(to: .celsius).value.rounded()
      return "\(Int(c))°C"
    }
  }
    
  private func configureForecastStack() {
    forecastStack.axis = .vertical
    forecastStack.spacing = 0
    contentStack.addArrangedSubview(forecastStack)
  }
  
  private func fetchDailyForecast() {
    configureForecastStack()
    
    let spinner = UIActivityIndicatorView(style: .medium)
    spinner.startAnimating()
    forecastStack.addArrangedSubview(spinner)
    
    Task {
      do {
        let forecast = try await WeatherManager.getDailyForecast(for: city)
        spinner.removeFromSuperview()
        buildForecastSection(with: forecast)
      } catch {
        spinner.removeFromSuperview()
      }
    }
  }
  
  private func buildForecastSection(with forecast: Forecast<DayWeather>) {
    let headerLabel = UILabel()
    headerLabel.text = "10-Day Forecast"
    headerLabel.font = .systemFont(ofSize: 17, weight: .semibold)
    headerLabel.textColor = .secondaryLabel
    forecastStack.addArrangedSubview(headerLabel)
    forecastStack.setCustomSpacing(12, after: headerLabel)
    
    forecastStack.addArrangedSubview(buildForecastContainer(with: forecast))
  }
  
  private func buildForecastContainer(with forecast: Forecast<DayWeather>) -> UIView {
    let tempUnit = PersistenceManager.tempUnit
    let calendar = Calendar.current
    
    let container = UIView()
    container.backgroundColor = .secondarySystemBackground
    container.layer.cornerRadius = 12
    container.layer.shadowColor = UIColor.black.cgColor
    container.layer.shadowRadius = 4
    container.layer.shadowOpacity = 0.12
    container.layer.shadowOffset = CGSize(width: 0, height: 10)
    container.clipsToBounds = false
    
    let rowsStack = UIStackView()
    rowsStack.axis = .vertical
    rowsStack.spacing = 0
    rowsStack.translatesAutoresizingMaskIntoConstraints = false
    container.addSubview(rowsStack)
    
    NSLayoutConstraint.activate([
      rowsStack.topAnchor.constraint(equalTo: container.topAnchor),
      rowsStack.leadingAnchor.constraint(equalTo: container.leadingAnchor),
      rowsStack.trailingAnchor.constraint(equalTo: container.trailingAnchor),
      rowsStack.bottomAnchor.constraint(equalTo: container.bottomAnchor),
    ])
    
    let days = Array(forecast.prefix(10))
    for (index, day) in days.enumerated() {
      let row = makeForecastRow(day: day, isToday: calendar.isDateInToday(day.date), tempUnit: tempUnit)
      rowsStack.addArrangedSubview(row)
      
      if index < days.count - 1 {
        let separator = makeSeparator()
        rowsStack.addArrangedSubview(separator)
        separator.leadingAnchor.constraint(equalTo: rowsStack.leadingAnchor, constant: 14).isActive = true
      }
    }
    
    return container
  }
  
  private func makeSeparator() -> UIView {
    let separator = UIView()
    separator.backgroundColor = .separator
    separator.translatesAutoresizingMaskIntoConstraints = false
    separator.heightAnchor.constraint(equalToConstant: 0.5).isActive = true
    return separator
  }
  
  private func makeForecastRow(day: DayWeather, isToday: Bool, tempUnit: TempUnit) -> UIView {
    let row = UIStackView()
    row.axis = .horizontal
    row.alignment = .center
    row.spacing = 8
    row.layoutMargins = UIEdgeInsets(top: 10, left: 14, bottom: 10, right: 14)
    row.isLayoutMarginsRelativeArrangement = true
    
    let dayLabel = UILabel()
    if isToday {
      dayLabel.text = "Today"
    } else {
      let formatter = DateFormatter()
      formatter.dateFormat = "EEE"
      dayLabel.text = formatter.string(from: day.date)
    }
    dayLabel.font = .systemFont(ofSize: 16, weight: .medium)
    dayLabel.widthAnchor.constraint(equalToConstant: 50).isActive = true
    
    let iconConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .medium)
    let iconView = UIImageView(image: UIImage(systemName: day.symbolName, withConfiguration: iconConfig))
    iconView.contentMode = .scaleAspectFit
    iconView.tintColor = .label
    iconView.widthAnchor.constraint(equalToConstant: 28).isActive = true
    
    let spacer = UIView()
    spacer.setContentHuggingPriority(.defaultLow, for: .horizontal)
    
    let lowLabel = UILabel()
    lowLabel.text = formatTemp(day.lowTemperature, unit: tempUnit)
    lowLabel.font = .systemFont(ofSize: 16, weight: .regular)
    lowLabel.textColor = .secondaryLabel
    lowLabel.textAlignment = .right
    lowLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
    
    let highLabel = UILabel()
    highLabel.text = formatTemp(day.highTemperature, unit: tempUnit)
    highLabel.font = .systemFont(ofSize: 16, weight: .semibold)
    highLabel.textAlignment = .right
    highLabel.widthAnchor.constraint(equalToConstant: 44).isActive = true
    
    row.addArrangedSubview(dayLabel)
    row.addArrangedSubview(iconView)
    row.addArrangedSubview(spacer)
    row.addArrangedSubview(lowLabel)
    row.addArrangedSubview(highLabel)
    
    return row
  }
}

//
//  WeatherCardView.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 2/29/26.
//

import UIKit
import WeatherKit

class WeatherCardView: UIView {
  
  private let stackView = UIStackView()
  private let weatherImage = UIImageView()
  private let tempLabel = UILabel()
  private let cityLabel = UILabel()
  
  var currentWeather: CurrentWeather?
  var currentCity: String?
  var tempUnit: TempUnit = .fahrenheit
  
  init(currentWeather: CurrentWeather?, currentCity: String?) {
    self.currentWeather = currentWeather
    self.currentCity = currentCity
    super.init(frame: .zero)
    setup()
  }
  
  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  private func setup() {
    configureCard()
    configureStackView()
    configureWeatherImage()
    configureTempLabel()
    configureCityLabel()
    applyGradientBackground()
  }

  private func configureCard() {
    layer.cornerRadius = 18
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowRadius = 6
    layer.shadowOpacity = 0.12
    layer.shadowOffset = CGSize(width: 0, height: 10)
    clipsToBounds = false
  }

  private func configureStackView() {
    stackView.axis = .vertical
    stackView.distribution = .equalSpacing
    stackView.alignment = .center
    stackView.spacing = 8
    stackView.isLayoutMarginsRelativeArrangement = true
    stackView.layoutMargins = UIEdgeInsets(top: 28, left: 16, bottom: 28, right: 16)
    
    stackView.addArrangedSubview(weatherImage)
    stackView.addArrangedSubview(tempLabel)
    stackView.addArrangedSubview(cityLabel)
    
    addSubview(stackView)
    stackView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
      stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
      stackView.topAnchor.constraint(equalTo: topAnchor),
      stackView.bottomAnchor.constraint(equalTo: bottomAnchor),
    ])
  }
  
  private func configureWeatherImage() {
    let symbolName = "\(currentWeather?.symbolName ?? "exclamationmark.icloud")"
    let config = UIImage.SymbolConfiguration(pointSize: 50, weight: .regular)
    weatherImage.image = UIImage(systemName: symbolName, withConfiguration: config)
    weatherImage.contentMode = .scaleAspectFit
    weatherImage.tintColor = iconTint(for: currentWeather?.condition, isDaylight: currentWeather?.isDaylight ?? true)
  }
  
  private func configureTempLabel() {
    let temperature = WeatherManager.convertTempUnitsAndConvertToReadable(
      tempUnit: tempUnit,
      currentWeather: currentWeather
    )
    let suffix = tempUnit == .fahrenheit ? "°F" : "°C"
    tempLabel.text = "\(temperature)\(suffix)"
    tempLabel.font = .systemFont(ofSize: 36, weight: .bold)
    tempLabel.textColor = labelColor(for: currentWeather?.condition, isDaylight: currentWeather?.isDaylight ?? true)
  }
  
  private func configureCityLabel() {
    cityLabel.text = currentCity ?? "City error"
    cityLabel.font = .systemFont(ofSize: 17, weight: .regular)
    cityLabel.textColor = labelColor(for: currentWeather?.condition, isDaylight: currentWeather?.isDaylight ?? true)
  }

  private func applyGradientBackground() {
    layer.sublayers?.filter { $0 is CAGradientLayer }.forEach { $0.removeFromSuperlayer() }
    
    let gradient = CAGradientLayer()
    gradient.cornerRadius = 18
    gradient.frame = bounds.isEmpty
    ? CGRect(x: 0, y: 0, width: 300, height: 180)
    : bounds
    
    let isDaylight = currentWeather?.isDaylight ?? true
    let (top, bottom) = gradientColors(for: currentWeather?.condition, isDaylight: isDaylight)
    gradient.colors = [top.cgColor, bottom.cgColor]
    gradient.startPoint = CGPoint(x: 0.5, y: 0)
    gradient.endPoint   = CGPoint(x: 0.5, y: 1)
    
    layer.insertSublayer(gradient, at: 0)
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    if let gradient = layer.sublayers?.first(where: { $0 is CAGradientLayer }) as? CAGradientLayer {
      gradient.frame = bounds
    }
  }
  
  private func gradientColors(for condition: WeatherCondition?, isDaylight: Bool) -> (UIColor, UIColor) {
    guard let condition else {
      return (.secondarySystemBackground, .secondarySystemBackground)
    }
    if isDaylight {
      switch condition {
      case .clear, .mostlyClear, .hot:
        return (UIColor(red: 1.00, green: 0.90, blue: 0.10, alpha: 1),
                UIColor(red: 1.00, green: 0.75, blue: 0.00, alpha: 1))
      case .rain, .drizzle, .heavyRain, .freezingRain, .freezingDrizzle,
          .wintryMix, .snow, .heavySnow, .sleet, .blizzard:
        return (UIColor(red: 0.30, green: 0.55, blue: 0.60, alpha: 1),
                UIColor(red: 0.55, green: 0.75, blue: 0.80, alpha: 1))
      default:
        return (UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1),
                UIColor(red: 0.78, green: 0.78, blue: 0.80, alpha: 1))
      }
    } else {
      switch condition {
      case .clear, .mostlyClear, .hot:
        return (UIColor(red: 0.05, green: 0.05, blue: 0.20, alpha: 1),
                UIColor(red: 0.15, green: 0.10, blue: 0.35, alpha: 1))
      case .rain, .drizzle, .heavyRain, .freezingRain, .freezingDrizzle,
          .wintryMix, .snow, .heavySnow, .sleet, .blizzard:
        return (UIColor(red: 0.10, green: 0.15, blue: 0.25, alpha: 1),
                UIColor(red: 0.20, green: 0.25, blue: 0.35, alpha: 1))
      default:
        return (UIColor(red: 0.12, green: 0.12, blue: 0.18, alpha: 1),
                UIColor(red: 0.22, green: 0.22, blue: 0.30, alpha: 1))
      }
    }
  }
  
  private func labelColor(for condition: WeatherCondition?, isDaylight: Bool) -> UIColor {
    guard let condition else { return .label }
    if isDaylight {
      switch condition {
      case .clear, .mostlyClear, .hot:
        return UIColor(red: 0.20, green: 0.15, blue: 0.00, alpha: 1)
      case .rain, .drizzle, .heavyRain, .freezingRain, .freezingDrizzle,
          .wintryMix, .snow, .heavySnow, .sleet, .blizzard:
        return UIColor(red: 0.10, green: 0.25, blue: 0.30, alpha: 1)
      default:
        return .darkGray
      }
    } else {
      return UIColor(red: 0.90, green: 0.90, blue: 0.95, alpha: 1)
    }
  }
  
  private func iconTint(for condition: WeatherCondition?, isDaylight: Bool) -> UIColor {
    labelColor(for: condition, isDaylight: isDaylight)
  }
  
  func configureUI() {
    configureWeatherImage()
    configureTempLabel()
    configureCityLabel()
    applyGradientBackground()
  }
}

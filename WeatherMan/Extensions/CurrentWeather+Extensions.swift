//
//  CurrentWeather+Extensions.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import Foundation
import WeatherKit

extension CurrentWeather {
  func convert(to unit: TempUnit) -> Double {
    let measurement = Measurement(value: temperature.value, unit: temperature.unit)
    let rounded = measurement.converted(to: unit.unitTemperature).value.rounded()
    return rounded == 0 ? 0 : rounded
  }
}

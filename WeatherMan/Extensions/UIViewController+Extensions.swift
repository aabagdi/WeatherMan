//
//  UIViewController+Extensions.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import UIKit

extension UIViewController {
  func presentWMAlert(title: String, message: String, buttonTitle: String = "OK") {
    let alertVC = WMAlertViewController(title: title, message: message, buttonTitle: buttonTitle)
    present(alertVC, animated: true)
  }
  
  func presentWMAlert(for error: WMError) {
    presentWMAlert(title: "Error", message: error.errorDescription ?? "An unknown error occurred.")
  }
}

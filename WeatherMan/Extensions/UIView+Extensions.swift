//
//  UIView+Extensions.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 2/27/26.
//

import UIKit

extension UIView {
  func addSubviews(_ views: UIView...) {
    for view in views {
      addSubview(view)
    }
  }
}

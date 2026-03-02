//
//  WMAlertViewController.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import UIKit

class WMAlertViewController: UIViewController {
  
  private let containerView = UIView()
  private let titleLabel = UILabel()
  private let messageLabel = UILabel()
  private let actionButton = UIButton(type: .system)
  
  private let alertTitle: String
  private let alertMessage: String
  private let buttonTitle: String
  
  init(title: String, message: String, buttonTitle: String = "OK") {
    self.alertTitle = title
    self.alertMessage = message
    self.buttonTitle = buttonTitle
    super.init(nibName: nil, bundle: nil)
    modalPresentationStyle = .overFullScreen
    modalTransitionStyle = .crossDissolve
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = UIColor.black.withAlphaComponent(0.75)
    configureContainerView()
    configureTitleLabel()
    configureMessageLabel()
    configureActionButton()
  }
  
  private func configureContainerView() {
    view.addSubview(containerView)
    containerView.backgroundColor = .systemBackground
    containerView.layer.cornerRadius = 16
    containerView.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      containerView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
      containerView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
      containerView.widthAnchor.constraint(equalToConstant: 280),
    ])
  }
  
  private func configureTitleLabel() {
    containerView.addSubview(titleLabel)
    titleLabel.text = alertTitle
    titleLabel.font = .systemFont(ofSize: 20, weight: .bold)
    titleLabel.textAlignment = .center
    titleLabel.numberOfLines = 1
    titleLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
      titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
    ])
  }
  
  private func configureMessageLabel() {
    containerView.addSubview(messageLabel)
    messageLabel.text = alertMessage
    messageLabel.font = .systemFont(ofSize: 14, weight: .regular)
    messageLabel.textColor = .secondaryLabel
    messageLabel.textAlignment = .center
    messageLabel.numberOfLines = 0
    messageLabel.translatesAutoresizingMaskIntoConstraints = false
    
    NSLayoutConstraint.activate([
      messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 12),
      messageLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      messageLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
    ])
  }
  
  private func configureActionButton() {
    containerView.addSubview(actionButton)
    actionButton.setTitle(buttonTitle, for: .normal)
    actionButton.titleLabel?.font = .systemFont(ofSize: 16, weight: .semibold)
    actionButton.backgroundColor = .systemBlue
    actionButton.setTitleColor(.white, for: .normal)
    actionButton.layer.cornerRadius = 10
    actionButton.translatesAutoresizingMaskIntoConstraints = false
    
    actionButton.addAction(UIAction { [weak self] _ in
      self?.dismiss(animated: true)
    }, for: .touchUpInside)
    
    NSLayoutConstraint.activate([
      actionButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 20),
      actionButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 20),
      actionButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -20),
      actionButton.heightAnchor.constraint(equalToConstant: 44),
      actionButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20),
    ])
  }
}

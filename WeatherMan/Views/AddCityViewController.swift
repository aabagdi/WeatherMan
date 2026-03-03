//
//  AddCityViewController.swift
//  WeatherMan
//
//  Created by Aadit Bagdi on 3/2/26.
//

import UIKit
import MapKit

class AddCityViewController: UIViewController {
  
  var onDismiss: (() -> Void)?
  
  private let searchBar = UISearchBar()
  private let tableView = UITableView()
  
  private let searchCompleter = MKLocalSearchCompleter()
  private var completions = [MKLocalSearchCompletion]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .systemBackground
    configureSearchBar()
    configureTableView()
    configureSearchCompleter()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    searchBar.becomeFirstResponder()
  }
  
  private func configureSearchBar() {
    searchBar.placeholder = "Search for a city"
    searchBar.delegate = self
    searchBar.searchBarStyle = .minimal
    searchBar.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(searchBar)
    
    NSLayoutConstraint.activate([
      searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    ])
  }
  
  private func configureTableView() {
    tableView.dataSource = self
    tableView.delegate = self
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "SuggestionCell")
    tableView.translatesAutoresizingMaskIntoConstraints = false
    view.addSubview(tableView)
    
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: searchBar.bottomAnchor),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
    ])
  }
  
  private func configureSearchCompleter() {
    searchCompleter.delegate = self
    searchCompleter.resultTypes = .address
  }
}

extension AddCityViewController: UISearchBarDelegate {
  func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
    if searchText.isEmpty {
      completions.removeAll()
      tableView.reloadData()
    } else {
      searchCompleter.queryFragment = searchText
    }
  }
  
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    searchBar.resignFirstResponder()
  }
}

extension AddCityViewController: MKLocalSearchCompleterDelegate {
  func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
    completions = completer.results
    tableView.reloadData()
  }
  
  func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: any Error) {
    presentWMAlert(for: .mapSearchError)
  }
}

extension AddCityViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    completions.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SuggestionCell", for: indexPath)
    let completion = completions[indexPath.row]
    
    var config = cell.defaultContentConfiguration()
    config.text = completion.title
    config.secondaryText = completion.subtitle
    cell.contentConfiguration = config
    
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let completion = completions[indexPath.row]
    let city = completion.title
    guard !PersistenceManager.retrieveSavedCities().contains(city) else {
      presentWMAlert(for: .duplicateCity)
      return
    }
    PersistenceManager.addCityToSaved(city: city)
    dismiss(animated: true) { [weak self] in
      self?.onDismiss?()
    }
  }
}

//
//  SettingsViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-03-25.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
  func shouldDismissSettings()
}

class SettingsViewController: UIViewController, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  weak var settingsDelegate: SettingsDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerLabel: UILabel!
  
  let settingsArray = ["Categories", "Users"]
  var selectedIndexPath: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    headerLabel.textColor = UIColor.text
    
    tableView.register(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 76))
    
    topLevelNavigationController?.detailColor = .text
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  func willBecomeCurrentTopLevelNavigableViewController() {
    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedRow, animated: true)
    }
  }
}

// MARK: - Table View Delegate Methods
extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.row == 0 {
      
      let categoryManagementViewController = CategoryManagementViewController(nibName: "CategoryManagementViewController", bundle: nil)
      if let topLevelNavigationController = topLevelNavigationController {
        topLevelNavigationController.push(categoryManagementViewController)
      }
      
    } else if indexPath.row == 1 {
      
      let userManagementViewController = UserManagementViewController(nibName: "UserManagementViewController", bundle: nil)
      if let topLevelNavigationController = topLevelNavigationController {
        topLevelNavigationController.push(userManagementViewController)
      }
    }
    
    selectedIndexPath = indexPath
  }
}

// MARK: - Table View Data Source Methods
extension SettingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingsArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
    cell.titleLabel.text = settingsArray[indexPath.row]
    return cell
  }
}

//
//  UserSelectionViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserSelectionViewController: UIViewController {
  
  weak var signInDelegate: SignInDelegate?
  
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var banditHatLabel: UILabel!
  @IBOutlet weak var budgetLabel: UILabel!
  
  @IBOutlet weak var tableView: UITableView!
  
  var userArray = [BKUser]()
  var themeColor = Utilities.getRandomColor()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.layer.cornerRadius = 8.0
    
    titleLabel.textColor = themeColor
    subtitleLabel.textColor = themeColor.withAlphaComponent(0.5)
    topView.backgroundColor = themeColor.withAlphaComponent(0.04)
    bottomView.backgroundColor = themeColor.withAlphaComponent(0.04)
    banditHatLabel.textColor = themeColor
    budgetLabel.textColor = themeColor
    
    tableView.register(UINib(nibName: "UserSelectionCell", bundle: nil), forCellReuseIdentifier: "UserSelectionCell")
    tableView.tableFooterView = UIView(frame: CGRect())
    tableView.separatorColor = themeColor.withAlphaComponent(0.1)
    tableView.rowHeight = 52.0
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

// MARK: - Table View Delegate
extension UserSelectionViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    Settings.signInWithUser(self.userArray[indexPath.row])
    signInDelegate?.signInCompleted()
  }
}

// MARK: - Table View Data Source
extension UserSelectionViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserSelectionCell") as! UserSelectionCell
    cell.user = userArray[indexPath.row]
    cell.themeColor = themeColor
    
    return cell
  }
}

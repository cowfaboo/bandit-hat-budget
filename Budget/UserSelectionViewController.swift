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
  
  @IBOutlet weak var tableView: UITableView!
  
  var userArray = [BKUser]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    cell.textLabel?.text = userArray[indexPath.row].name
    return cell
  }
}

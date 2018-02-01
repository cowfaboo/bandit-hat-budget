//
//  UserFilterViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-26.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol UserFilterDelegate: class {
  func shouldDismissUserFilter()
}

class UserFilterViewController: UIViewController, TableViewController {
  
  weak var delegate: UserFilterDelegate?
  
  let everyoneCellHeight: CGFloat = 56.0
  let userCellHeight: CGFloat = 44.0
  
  @IBOutlet weak var tableView: UITableView!
  
  var userArray = [BKUser]()
  var currentUser: BKUser?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UINib(nibName: "UserFilterCell", bundle: nil), forCellReuseIdentifier: "UserFilterCell")
    tableView.tableFooterView = UIView(frame: CGRect())
    tableView.separatorColor = UIColor.text.withAlphaComponent(0.1)
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      if let viewContainer = self.parent as? ViewContainer {
        let height = min(CGFloat(userArray.count) * self.userCellHeight + self.everyoneCellHeight, 308)
        viewContainer.contentHeightDidChange(height)
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
}

extension UserFilterViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    if indexPath.row == 0 {
      currentUser = nil
      tableView.reloadData()
      ContainerViewController.sharedInstance.dataNavigationController.currentViewController.userFilter = nil
    } else {
      currentUser = userArray[indexPath.row - 1]
      tableView.reloadData()
      ContainerViewController.sharedInstance.dataNavigationController.currentViewController.userFilter = userArray[indexPath.row - 1]
    }
    
    delegate?.shouldDismissUserFilter()
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    if indexPath.row == 0 {
      return everyoneCellHeight
    } else {
      return userCellHeight
    }
  }
}

extension UserFilterViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userArray.count + 1
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserFilterCell") as! UserFilterCell
    
    if indexPath.row == 0 {
      cell.user = nil
      if currentUser == nil {
        cell.userIsSelected = true
      } else {
        cell.userIsSelected = false
      }
    } else {
      cell.user = userArray[indexPath.row - 1]
      if currentUser == cell.user {
        cell.userIsSelected = true
      } else {
        cell.userIsSelected = false
      }
    }
    
    cell.themeColor = UIColor.text
    
    return cell
  }
}

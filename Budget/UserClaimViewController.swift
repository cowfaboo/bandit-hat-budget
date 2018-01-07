//
//  UserClaimViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserClaimViewController: UIViewController, TopLevelNavigable {

  var topLevelNavigationController: TopLevelNavigationController?
  
  @IBOutlet weak var backgroundColorView: UIView!
  @IBOutlet weak var welcomeLabel: UILabel!
  @IBOutlet weak var groupLabel: UILabel!
  @IBOutlet weak var creationTitleLabel: UILabel!
  @IBOutlet weak var newUserTextField: UITextField!
  @IBOutlet weak var newUserCheckmarkImageView: UIImageView!
  @IBOutlet weak var selectionTitleLabel: UILabel!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var confirmButton: BHButton!
  
  var userArray = [BKUser]()
  var currentUser: BKUser?
  
  var backgroundColor: UIColor = UIColor.palette[2]
  var foregroundColor: UIColor = UIColor.white
  
  var shouldUseLightTheme: Bool = false {
    didSet {
      if shouldUseLightTheme {
        backgroundColor = .white
        foregroundColor = UIColor.palette[2]
      } else {
        backgroundColor = UIColor.palette[2]
        foregroundColor = .white
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if !Settings.hasClaimedUser() {
      self.topLevelNavigationController?.canGoBack = false
      welcomeLabel.isHidden = false
    }
    
    if let currentGroup = BKGroup.currentGroup() {
      groupLabel.text = currentGroup.name
    }
    
    groupLabel.textColor = foregroundColor
    welcomeLabel.textColor = foregroundColor
    
    selectionTitleLabel.alpha = 0.0
    
    backgroundColorView.backgroundColor = backgroundColor.withAlphaComponent(0.7)
    
    confirmButton.backgroundColor = backgroundColor
    confirmButton.themeColor = foregroundColor
    confirmButton.isEnabled = false
    
    tableView.register(UINib(nibName: "UserSelectionCell", bundle: nil), forCellReuseIdentifier: "UserSelectionCell")
    tableView.tableFooterView = UIView(frame: CGRect())
    
    newUserTextField.attributedPlaceholder = NSAttributedString(string: "Your Name", attributes: [NSAttributedStringKey.foregroundColor: foregroundColor.withAlphaComponent(0.5)])
    newUserTextField.tintColor = foregroundColor
    newUserTextField.textColor = foregroundColor
    
    newUserCheckmarkImageView.tintColor = foregroundColor
    newUserCheckmarkImageView.isHidden = true
    
    if shouldUseLightTheme {
      creationTitleLabel.textColor = foregroundColor
      selectionTitleLabel.textColor = foregroundColor
    } else {
      creationTitleLabel.textColor = backgroundColor
      selectionTitleLabel.textColor = backgroundColor
    }
    
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
      
      if self.userArray.count > 0 {
        self.selectionTitleLabel.alpha = 1.0
      }
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    if shouldUseLightTheme {
      return .default
    } else {
      return .lightContent
    }
  }
  
  @IBAction func backgroundButtonTapped() {
    view.endEditing(true)
  }
  
  @IBAction func confirmButtonTapped() {
    
    if let currentUser = currentUser {
      claimUser(currentUser)
    } else {
      createNewUser()
    }  
  }
  
  func claimUser(_ user: BKUser) {
    Settings.claimUser(user)
    
    if let topLevelNavigationController = self.topLevelNavigationController {
      topLevelNavigationController.topLevelViewControllerDelegate?.topLevelViewControllerDismissed(topLevelNavigationController)
    }
  }
  
  func createNewUser() {
    
    guard let userName = newUserTextField.text?.sanitizeHouseholdOrUserName(), userName.count > 0 else {
      print("no user selected")
      return
    }
    
    BKSharedBasicRequestClient.createUser(withName: userName) { (success, user) in
      
      guard success, let user = user else {
        print("failed to create user")
        return
      }
      
      Settings.claimUser(user)
      
      if let topLevelNavigationController = self.topLevelNavigationController {
        topLevelNavigationController.topLevelViewControllerDelegate?.topLevelViewControllerDismissed(topLevelNavigationController)
      }
    }
  }
  
  func refreshConfirmButton(withName name: String?) {
    
    if let name = name?.sanitizeHouseholdOrUserName(), name.count > 0 {
      confirmButton.setTitle("Continue as \(name)", for: .normal)
      confirmButton.isEnabled = true
      return
    } else {
      confirmButton.setTitle("Continue", for: .normal)
      confirmButton.isEnabled = false
    }
  }
}

extension UserClaimViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    var previousIndexPath: IndexPath?
    if let currentUser = currentUser {
      previousIndexPath = IndexPath(row: userArray.index(of: currentUser)!, section: 0)
    }
    
    currentUser = userArray[indexPath.row]
    newUserCheckmarkImageView.isHidden = true
    if let previousIndexPath = previousIndexPath {
      tableView.reloadRows(at: [indexPath, previousIndexPath], with: .none)
    } else {
      tableView.reloadRows(at: [indexPath], with: .none)
    }
    
    view.endEditing(true)
    
    if let name = currentUser?.name {
      refreshConfirmButton(withName: name)
    } else {
      refreshConfirmButton(withName: nil)
    }
  }
  
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 44.0
  }
  
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    view.endEditing(true)
  }
}

extension UserClaimViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserSelectionCell") as! UserSelectionCell
    
    cell.user = userArray[indexPath.row]
    if currentUser == cell.user {
      cell.userIsSelected = true
    } else {
      cell.userIsSelected = false
    }
    
    
    cell.themeColor = foregroundColor
    
    return cell
  }
}

extension UserClaimViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    view.endEditing(true)
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    newUserCheckmarkImageView.isHidden = false
    currentUser = nil
    tableView.reloadData()
    
    refreshConfirmButton(withName: newUserTextField.text)
  }
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    refreshConfirmButton(withName: newString)
    
    return true
  }
}

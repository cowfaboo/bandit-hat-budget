//
//  UserManagementViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2018-01-02.
//  Copyright © 2018 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserManagementViewController: UIViewController, InteractivePresenter, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var createButton: UIButton!
  
  var userArray = [BKUser]()
  var selectedIndexPath: IndexPath?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    createButton.tintColor = .text
    
    tableView.register(UINib(nibName: "UserManagementCell", bundle: nil), forCellReuseIdentifier: "UserManagementCell")
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
    
    tableView.tableFooterView = UIView(frame: CGRect())
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func createButtonTapped() {
    let userDetailViewController = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
    userDetailViewController.delegate = self
    let topSlideViewController = TopSlideViewController(presenting: userDetailViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  func presentUserDetailView(forUser user: BKUser) {
    let userDetailViewController = UserDetailViewController(nibName: "UserDetailViewController", bundle: nil)
    userDetailViewController.delegate = self
    userDetailViewController.user = user
    let topSlideViewController = TopSlideViewController(presenting: userDetailViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  // MARK: - Interactive Presenter Methods
  func interactivePresentationDismissed() {
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
}

// MARK: - Table View Data Source Methods
extension UserManagementViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return userArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "UserManagementCell") as! UserManagementCell
    cell.user = userArray[indexPath.row]
    return cell
  }
}

// MARK: - Table View Delegate Methods
extension UserManagementViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    let user = userArray[indexPath.row]
    presentUserDetailView(forUser: user)
  }
}

// MARK: - User Detail Delegate Methods
extension UserManagementViewController: UserDetailDelegate {
  
  func shouldDismissUserDetailView() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
  
  func didCreateNewUser() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
  
  func didBecomeNewUser() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
  
  func didDeleteUser() {
    
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
}

// MARK: - Category Detail Delegate Methods
/*extension UserManagementViewController: UserDetailDelegate {
  
  func shouldDismissUserDetailView() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
  
  func didCreateNewUser() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
  
  func didUpdateUser() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
  
  func didDeleteUser() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
      
      guard success, let userArray = userArray else {
        print("failed to get users")
        return
      }
      
      self.userArray = userArray
      self.tableView.reloadData()
    }
  }
}*/

// MARK: - Top Slide Delegate Methods
extension UserManagementViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension UserManagementViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentationAnimator.presenting = true
    return presentationAnimator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentationAnimator.presenting = false
    return presentationAnimator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if presentationAnimator.interactive {
      presentationAnimator.presenting = true
      return presentationAnimator
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if presentationAnimator.interactive {
      presentationAnimator.presenting = false
      return presentationAnimator
    }
    return nil
  }
}

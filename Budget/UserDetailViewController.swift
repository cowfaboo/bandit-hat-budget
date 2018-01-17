//
//  UserDetailViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2018-01-02.
//  Copyright © 2018 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol UserDetailDelegate: class {
  func shouldDismissUserDetailView()
  func didCreateNewUser()
  func didDeleteUser()
  func didBecomeNewUser()
}

enum UserDetailMode {
  case create
  case view
}

class UserDetailViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  weak var delegate: UserDetailDelegate?
  
  @IBOutlet weak var tintView: UIView!
  
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var nameTextField: UITextField!
  @IBOutlet private weak var actionButton: BHButton!
  @IBOutlet private weak var deleteButton: BHButton!
  @IBOutlet private weak var inUseDescriptionLabel: UILabel!
  
  @IBOutlet private weak var nameTextFieldHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var nameTextFieldTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var nameUnderlineViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var deleteButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var deleteButtonLeadingConstraint: NSLayoutConstraint!
  
  private var userDetailMode = UserDetailMode.create {
    didSet {
      if userDetailMode == .create {
        transitionToCreateMode()
      } else if userDetailMode == .view {
        transitionToViewMode()
      }
    }
  }
  
  var user: BKUser?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    
    nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    
    closeButton.tintColor = .text
    titleLabel.tintColor = .text
    actionButton.themeColor = .text
    deleteButton.themeColor = UIColor.negative.withAlphaComponent(0.75)
    nameTextField.textColor = .text
    nameTextField.tintColor = .text
    inUseDescriptionLabel.textColor = .text
    
    if user == nil {
      userDetailMode = .create
    } else {
      userDetailMode = .view
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func transitionToCreateMode() {
    actionButton.setTitle("Create", for: .normal)
    titleLabel.text = "New User"
    nameTextField.isEnabled = true
    
    nameTextFieldHeightConstraint.constant = 44
    nameTextFieldTopConstraint.constant = 16
    nameUnderlineViewHeightConstraint.constant = 1
    
    nameTextField.isHidden = false
    
    updateFormValidity()
    
    deleteButtonWidthConstraint.constant = 0
    deleteButtonLeadingConstraint.constant = 0
    
    if let viewContainer = self.parent as? ViewContainer {
      viewContainer.contentHeightDidChange(215)
    }
    
    view.layoutIfNeeded()
  }
  
  func transitionToViewMode() {
    actionButton.setTitle("Become this user", for: .normal)
    titleLabel.text = user?.name
    nameTextField.isEnabled = false
    
    nameTextFieldHeightConstraint.constant = 0
    nameTextFieldTopConstraint.constant = 0
    nameTextField.isHidden = true
    nameUnderlineViewHeightConstraint.constant = 0
    
    actionButton.isEnabled = true
    
    deleteButtonWidthConstraint.constant = (view.frame.width - 32 - 12) / 3
    deleteButtonLeadingConstraint.constant = 12
    
    
    
    if Settings.claimedUserID() == user!.cloudID {
      actionButton.isHidden = true
      deleteButton.isHidden = true
      inUseDescriptionLabel.isHidden = false
      inUseDescriptionLabel.text = "You are currently tracking expenses as \(user!.name!)."
      if let viewContainer = self.parent as? ViewContainer {
        viewContainer.contentHeightDidChange(154)
      }
    } else {
      actionButton.isHidden = false
      deleteButton.isHidden = false
      inUseDescriptionLabel.isHidden = true
      if let viewContainer = self.parent as? ViewContainer {
        viewContainer.contentHeightDidChange(154)
      }
    }
  }
  
  @IBAction func closeButtonTapped() {
    delegate?.shouldDismissUserDetailView()
  }
  
  @IBAction func actionButtonTapped() {
    if userDetailMode == .create {
      createUser()
    } else if userDetailMode == .view {
      becomeUser()
    }
  }
  
  @IBAction func deleteButtonTapped() {
    
    guard let user = user else {
      return
    }
    
    let cancelAction = BHAlertAction(withTitle: "Cancel") {
      self.dismiss(animated: true, completion: nil)
    }
    
    let deleteAction = BHAlertAction(withTitle: "Delete", color: UIColor.negative) {
      self.deleteUser() { (success) in
        
        self.dismiss(animated: true, completion: nil)
        
        if success {
          self.delegate?.didDeleteUser()
        }
      }
    }
    
    let alertViewController = BHAlertViewController(withTitle: "Delete User?", message: "Are you sure you want to delete \"\(user.name!)\"?", actions: [cancelAction, deleteAction])
    let topSlideViewController = TopSlideViewController(presenting: alertViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
    
  }
  
  func createUser() {
    let name = nameTextField.text!
    
    BKSharedBasicRequestClient.createUser(withName: name) { (success, user) in
      guard success, let _ = user else {
        print("failed to update user")
        return
      }
      
      self.view.endEditing(true)
      self.delegate?.didCreateNewUser()
    }
  }
  
  func becomeUser() {
    
    guard let user = user else {
      return
    }
    
    let cancelAction = BHAlertAction(withTitle: "Cancel") {
      self.dismiss(animated: true, completion: nil)
    }
    
    let becomeAction = BHAlertAction(withTitle: "Confirm", color: UIColor.positive) {
      Settings.claimUser(user)
      self.delegate?.didBecomeNewUser()
      self.dismiss(animated: true, completion: nil)
    }
    
    let alertViewController = BHAlertViewController(withTitle: "Become \(user.name!)?", message: "Are you sure you want to start tracking expenses as \(user.name!)?", actions: [cancelAction, becomeAction])
    let topSlideViewController = TopSlideViewController(presenting: alertViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  func deleteUser(completion: @escaping (Bool) -> ()) {
    
    guard let user = user else {
      completion(false)
      return
    }
    
    BKSharedBasicRequestClient.delete(user: user) { (success) in
      guard success else {
        print("failed to delete user")
        completion(false)
        return
      }
      
      completion(true)
    }
  }
  
  @objc func nameTextFieldDidChange() {
    updateFormValidity()
  }
  
  func updateFormValidity() {
    
    let name = nameTextField.text ?? ""
    
    if name.count > 0 {
      actionButton.isEnabled = true
    } else {
      actionButton.isEnabled = false
    }
  }
  
  @objc func keyboardDidHide(_ notification: NSNotification) {
    print("keyboard did hide")
    if let topSlideViewController = parent as? TopSlideViewController {
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop
      
      UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
        topSlideViewController.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
  
  @objc func keyboardDidShow(_ notification: NSNotification) {
    print("keyboard did show")
    guard let topSlideViewController = parent as? TopSlideViewController else {
      return
    }
    
    let currentKeyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
    let availableSpace = Utilities.screenHeight - currentKeyboardHeight
    let inputPositionInContainer = nameTextField.frame.origin.y
    let idealInputPositionOnScreen = inputPositionInContainer + topSlideViewController.originalDistanceFromTop
    let lowestIdealPosition = (availableSpace / 2) - (nameTextField.frame.size.height)
    let containerHeight = topSlideViewController.containerView.frame.size.height
    
    func idealTextInputIsInTopCenterRange() -> Bool {
      return idealInputPositionOnScreen < lowestIdealPosition && idealInputPositionOnScreen > 16
    }
    
    func textInputFitsWhenBottomVisible() -> Bool {
      let containerTop = availableSpace - 16 - containerHeight
      let inputPositionOnScreen = inputPositionInContainer + containerTop
      
      return inputPositionOnScreen > 16
    }
    
    func containerViewCanBeCentered() -> Bool {
      return containerHeight < availableSpace - 32
    }
    
    func entireViewFits() -> Bool {
      return containerHeight + topSlideViewController.originalDistanceFromTop + 16 < availableSpace
    }
    
    // check if entire view fits comfortably in available space already;
    // then, try to center whole view;
    // then, try to get whole view 16 px from keyboard;
    // then, move to ideal position if its acceptable spot for text input;
    // then, center text input in top half of available space
    
    if entireViewFits() {
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop
    } else if containerViewCanBeCentered() {
      topSlideViewController.containerViewTopConstraint.constant = (availableSpace - containerHeight) / 2
    } else if textInputFitsWhenBottomVisible() {
      topSlideViewController.containerViewTopConstraint.constant = availableSpace - 16 - containerHeight
    } else if idealTextInputIsInTopCenterRange() {
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop
    } else {
      let distanceToTravel = idealInputPositionOnScreen - ((availableSpace / 4) - (nameTextField.frame.size.height / 2))
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop - distanceToTravel
    }
    
    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
      topSlideViewController.view.layoutIfNeeded()
    }, completion: nil)
  }
}

extension UserDetailViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder()
    return true
  }
}

// MARK: - Top Slide Delegate Methods
extension UserDetailViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension UserDetailViewController: UIViewControllerTransitioningDelegate {
  
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

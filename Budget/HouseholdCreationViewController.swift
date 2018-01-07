//
//  HouseholdCreationViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-09-14.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class HouseholdCreationViewController: UIViewController, InteractivePresenter, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var confirmPasswordTextField: UITextField!
  @IBOutlet weak var nameUnderlineView: UIView!
  @IBOutlet weak var passwordUnderlineView: UIView!
  @IBOutlet weak var confirmPasswordUnderlineView: UIView!
  @IBOutlet weak var createButton: BHButton!
  @IBOutlet weak var createButtonContainerViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet weak var backgroundColorView: UIView!
  
  
  override func viewWillAppear(_ animated: Bool) {
    nameTextField.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    backgroundColorView.backgroundColor = UIColor.palette[2].withAlphaComponent(0.7)
    nameUnderlineView.backgroundColor = UIColor.palette[2]
    passwordUnderlineView.backgroundColor = UIColor.palette[2]
    confirmPasswordUnderlineView.backgroundColor = UIColor.palette[2]
    createButton.themeColor = UIColor.palette[2]
    
    nameTextField.attributedPlaceholder = NSAttributedString(string: "Household Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    confirmPasswordTextField.attributedPlaceholder = NSAttributedString(string: "Confirm Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)])
    
    nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
    confirmPasswordTextField.addTarget(self, action: #selector(confirmPasswordTextFieldDidChange), for: .editingChanged)
    
    updateInitialFormValidity()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  @IBAction func createButtonTapped() {
    
    if let invalidString = checkSecondaryFormValidity() {
      
      presentSimpleAlert(withTitle: "Whoops...", andMessage: invalidString)
      
    } else {
      
      BKSharedBasicRequestClient.createGroup(withName: self.nameTextField.text!.sanitizeHouseholdOrUserName(), password: self.passwordTextField.text!) { (success, errorMessage, group) in
        
        guard success, let _ = group else {
          
          let errorMessage = errorMessage ?? "Something went wrong."
          self.presentSimpleAlert(withTitle: "Uh oh...", andMessage: errorMessage)
          return
        }
        
        Utilities.setDataViewNeedsUpdate()
        
        let userClaimViewController = UserClaimViewController(nibName: "UserClaimViewController", bundle: nil)
        
        if let topLevelNavigationController = self.topLevelNavigationController {
          topLevelNavigationController.push(userClaimViewController)
        }
      }
    }
  }
  
  @objc func keyboardWillHide(_ notification: NSNotification) {
    createButtonContainerViewBottomConstraint.constant = 0
    view.layoutIfNeeded()
  }
  
  @objc func keyboardWillShow(_ notification: NSNotification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
    
    if createButtonContainerViewBottomConstraint.constant == keyboardSize.height {
      return
    }
    
    createButtonContainerViewBottomConstraint.constant = keyboardSize.height
    view.layoutIfNeeded()
  }
}

// MARK: - Text Field Delegate Methods
extension HouseholdCreationViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == nameTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField == passwordTextField {
      confirmPasswordTextField.becomeFirstResponder()
    } else {
      view.endEditing(true)
    }
    
    return true
  }
  
  @objc func nameTextFieldDidChange() {
    updateInitialFormValidity()
  }
  
  @objc func passwordTextFieldDidChange() {
    updateInitialFormValidity()
  }
  
  @objc func confirmPasswordTextFieldDidChange() {
    updateInitialFormValidity()
  }
  
  
  func updateInitialFormValidity() {
    
    let name = nameTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    let confirmPassword = confirmPasswordTextField.text ?? ""
    
    if name.count > 0 && password.count > 0 && confirmPassword.count > 0 {
      createButton.isEnabled = true
    } else {
      createButton.isEnabled = false
    }
  }
  
  func checkSecondaryFormValidity() -> String? {
    
    let name = nameTextField.text?.sanitizeHouseholdOrUserName() ?? ""
    let password = passwordTextField.text ?? ""
    let confirmPassword = confirmPasswordTextField.text ?? ""
    
    if name.isEmpty || name.range(of: "[^a-zA-Z0-9_ ]", options: .regularExpression) != nil {
      return "Your household name can only contain letters, numbers, spaces and underscores."
    }
    
    if password.count < 8 {
      return "Your password must be at least 8 characters long."
    }
    
    if password != confirmPassword {
      return "The entered passwords don't match."
    }
    
    return nil
  }
}

// MARK: - Top Slide Delegate Methods
extension HouseholdCreationViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension HouseholdCreationViewController: UIViewControllerTransitioningDelegate {
  
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

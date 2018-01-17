//
//  HouseholdSignInViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-09-14.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class HouseholdSignInViewController: UIViewController, InteractivePresenter, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var nameUnderlineView: UIView!
  @IBOutlet weak var passwordUnderlineView: UIView!
  @IBOutlet weak var createButton: BHButton!
  @IBOutlet weak var createButtonContainerViewBottomConstraint: NSLayoutConstraint!
  
  
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
    
    view.backgroundColor = UIColor.palette[2].withAlphaComponent(0.8)
    nameUnderlineView.backgroundColor = UIColor.palette[2]
    passwordUnderlineView.backgroundColor = UIColor.palette[2]
    createButton.themeColor = UIColor.palette[2]
    
    nameTextField.attributedPlaceholder = NSAttributedString(string: "Household Name", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.25)])
    passwordTextField.attributedPlaceholder = NSAttributedString(string: "Password", attributes: [NSAttributedStringKey.foregroundColor: UIColor.black.withAlphaComponent(0.25)])
    
    nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    passwordTextField.addTarget(self, action: #selector(passwordTextFieldDidChange), for: .editingChanged)
    
    updateFormValidity()
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
  
  @IBAction func signInButtonTapped() {
      
    BKSharedBasicRequestClient.signIn(withName: nameTextField.text!.sanitizeHouseholdOrUserName(), password: passwordTextField.text!) { (success, errorMessage, group) in
      
      guard success, let _ = group else {
        
        let errorMessage = errorMessage ?? "Something went wrong."
        self.presentSimpleAlert(withTitle: "Whoops...", andMessage: errorMessage)
        return
      }
      
     Utilities.updateDataViews()
      
      let userClaimViewController = UserClaimViewController(nibName: "UserClaimViewController", bundle: nil)
      
      if let topLevelNavigationController = self.topLevelNavigationController {
        topLevelNavigationController.push(userClaimViewController)
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
extension HouseholdSignInViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == nameTextField {
      passwordTextField.becomeFirstResponder()
    } else {
      view.endEditing(true)
    }
    
    return true
  }
  
  @objc func nameTextFieldDidChange() {
    updateFormValidity()
  }
  
  @objc func passwordTextFieldDidChange() {
    updateFormValidity()
  }
  
  func updateFormValidity() {
    
    let name = nameTextField.text ?? ""
    let password = passwordTextField.text ?? ""
    
    if name.count > 0 && password.count > 0 {
      createButton.isEnabled = true
    } else {
      createButton.isEnabled = false
    }
  }
}

// MARK: - Top Slide Delegate Methods
extension HouseholdSignInViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension HouseholdSignInViewController: UIViewControllerTransitioningDelegate {
  
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

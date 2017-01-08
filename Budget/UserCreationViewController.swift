//
//  UserCreationViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserCreationViewController: UIViewController {
  
  weak var signInDelegate: SignInDelegate?
    
  @IBOutlet weak var topView: UIView!
  @IBOutlet weak var titleLabel: UILabel!
  @IBOutlet weak var subtitleLabel: UILabel!
  
  @IBOutlet weak var bottomView: UIView!
  @IBOutlet weak var banditHatLabel: UILabel!
  @IBOutlet weak var budgetLabel: UILabel!
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var nameUnderlineView: UIView!
  @IBOutlet weak var createButton: BHButton!
  
  var themeColor = UIColor.text
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    self.view.layer.cornerRadius = 8.0
    
    titleLabel.textColor = themeColor
    subtitleLabel.textColor = themeColor.withAlphaComponent(0.5)
    topView.backgroundColor = themeColor.withAlphaComponent(0.04)
    bottomView.backgroundColor = themeColor.withAlphaComponent(0.04)
    banditHatLabel.textColor = themeColor
    budgetLabel.textColor = themeColor
    
    nameTextField.attributedPlaceholder = NSAttributedString(string: "Name", attributes: [NSForegroundColorAttributeName: themeColor.withAlphaComponent(0.5)])
    nameTextField.tintColor = themeColor
    nameTextField.textColor = themeColor
    nameUnderlineView.backgroundColor = themeColor.withAlphaComponent(0.2)
    
    createButton.isEnabled = false
    createButton.themeColor = themeColor
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func createButtonTapped() {
    
    guard let text = nameTextField.text, text.characters.count > 0 else {
      print("no text entered")
      return
    }
    
    BKSharedBasicRequestClient.createUser(withName: text) { (success, user) in
      
      guard success, let user = user else {
        print("failed to create user")
        return
      }
      
      Settings.signInWithUser(user)
      self.signInDelegate?.signInCompleted()
    }
  }
}

// MARK: - Text Field Delegate Methods
extension UserCreationViewController: UITextFieldDelegate {
  
  func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    
    let newString = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    
    if newString.characters.count > 0 {
      createButton.isEnabled = true
    } else {
      createButton.isEnabled = false
    }
    return true
  }
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    nameTextField.resignFirstResponder()
    return false
  }
}

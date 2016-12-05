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
  
  @IBOutlet weak var nameTextField: UITextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
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

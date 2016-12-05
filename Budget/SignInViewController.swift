//
//  SignInViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol SignInDelegate: class {
  func signInCompleted()
}

class SignInViewController: UIViewController {

  weak var signInDelegate: SignInDelegate?
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func createUserButtonTapped() {
    
    let userCreationViewController = UserCreationViewController(nibName: "UserCreationViewController", bundle: nil)
    userCreationViewController.signInDelegate = signInDelegate
    
    if let navigationController = navigationController {
      navigationController.pushViewController(userCreationViewController, animated: true)
    }
  }
  
  @IBAction func chooseUserButtonTapped() {
    
    let userSelectionViewController = UserSelectionViewController(nibName: "UserSelectionViewController", bundle: nil)
    userSelectionViewController.signInDelegate = signInDelegate
    
    if let navigationController = navigationController {
      navigationController.pushViewController(userSelectionViewController, animated: true)
    }
  }
}

//
//  SignInViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class SignInViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func createUserButtonTapped() {
    
    let userCreationViewController = UserCreationViewController(nibName: "UserCreationViewController", bundle: nil)
    
    if let navigationController = navigationController {
      navigationController.pushViewController(userCreationViewController, animated: true)
    }
  }
  
  @IBAction func chooseUserButtonTapped() {
    
    let userSelectionViewController = UserSelectionViewController(nibName: "UserSelectionViewController", bundle: nil)
    
    if let navigationController = navigationController {
      navigationController.pushViewController(userSelectionViewController, animated: true)
    }
  }
}

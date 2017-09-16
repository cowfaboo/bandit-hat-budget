//
//  HouseholdLaunchViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-09-12.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol HouseholdLaunchDelegate: class {
  func householdLaunched()
}

class HouseholdLaunchViewController: UIViewController {
  
  weak var householdLaunchDelegate: HouseholdLaunchDelegate?
  
  @IBOutlet weak var createButton: BHButton!
  @IBOutlet weak var signInButton: BHButton!
  @IBOutlet weak var backgroundColorView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    backgroundColorView.backgroundColor = UIColor.palette[2].withAlphaComponent(0.8)
    
    createButton.themeColor = UIColor.palette[2]
    signInButton.backgroundColor = UIColor.palette[2]
    signInButton.themeColor = UIColor.white
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func createButtonTapped() {
    
    let householdCreationViewController = HouseholdCreationViewController(nibName: "HouseholdCreationViewController", bundle: nil)
    
    if let navigationController = navigationController {
      navigationController.pushViewController(householdCreationViewController, animated: true)
    }
  }
  
  @IBAction func signInButtonTapped() {
    
    let householdSignInViewController = HouseholdSignInViewController(nibName: "HouseholdSignInViewController", bundle: nil)
    
    if let navigationController = navigationController {
      navigationController.pushViewController(householdSignInViewController, animated: true)
    }
  }
  
  /*@IBAction func signInButtonTapped() {
    
    let groupName = groupNameTextField.text!
    let password = passwordTextField.text!
    
    BKSharedBasicRequestClient.signIn(withName: groupName, password: password) { (success, group) in
      
      guard success, let _ = group else {
        print("failed to sign in")
        return
      }
      
      Utilities.setDataViewNeedsUpdate()
      print("signed in successfully")
      // call some sort of "signed in" delegate method here that will trigger dismissal of this view controller
    }
  }
  
  @IBAction func signUpButtonTapped() {
    
    let groupName = groupNameTextField.text!
    let password = passwordTextField.text!
    
    BKSharedBasicRequestClient.createGroup(withName: groupName, password: password) { (success, group) in
      
      guard success, let _ = group else {
        print("failed to sign up")
        return
      }
      
      Utilities.setDataViewNeedsUpdate()
      print("signed up successfully")
      // call some sort of "signed in" delegate method here that will trigger dismissal of this view controller
    }
  }*/
}

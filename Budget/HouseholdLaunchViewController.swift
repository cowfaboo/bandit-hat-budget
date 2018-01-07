//
//  HouseholdLaunchViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-09-12.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class HouseholdLaunchViewController: UIViewController, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  @IBOutlet weak var createButton: BHButton!
  @IBOutlet weak var signInButton: BHButton!
  @IBOutlet weak var backgroundColorView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.clipsToBounds = true
    backgroundColorView.backgroundColor = UIColor.palette[2].withAlphaComponent(0.7)
    
    createButton.themeColor = UIColor.palette[2]
    signInButton.backgroundColor = UIColor.palette[2]
    signInButton.themeColor = UIColor.white
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  override var preferredStatusBarStyle: UIStatusBarStyle {
    return .lightContent
  }
  
  @IBAction func createButtonTapped() {
    
    let householdCreationViewController = HouseholdCreationViewController(nibName: "HouseholdCreationViewController", bundle: nil)
    
    if let topLevelNavigationController = topLevelNavigationController {
      topLevelNavigationController.push(householdCreationViewController)
    }
  }
  
  @IBAction func signInButtonTapped() {
    
    let householdSignInViewController = HouseholdSignInViewController(nibName: "HouseholdSignInViewController", bundle: nil)
    
    if let topLevelNavigationController = topLevelNavigationController {
      topLevelNavigationController.push(householdSignInViewController)
    }
  }
}

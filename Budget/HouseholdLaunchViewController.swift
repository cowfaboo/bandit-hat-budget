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

class HouseholdLaunchViewController: UIViewController, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  weak var householdLaunchDelegate: HouseholdLaunchDelegate?
  
  @IBOutlet weak var createButton: BHButton!
  @IBOutlet weak var signInButton: BHButton!
  @IBOutlet weak var backgroundColorView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    //isInteractivelyDismissable = false
    
    view.clipsToBounds = true
    backgroundColorView.backgroundColor = UIColor.palette[2].withAlphaComponent(0.8)
    
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
    householdCreationViewController.householdLaunchDelegate = householdLaunchDelegate
    
    if let topLevelNavigationController = topLevelNavigationController {
      topLevelNavigationController.push(householdCreationViewController)
    }
  }
  
  @IBAction func signInButtonTapped() {
    
    let householdSignInViewController = HouseholdSignInViewController(nibName: "HouseholdSignInViewController", bundle: nil)
    householdSignInViewController.householdLaunchDelegate = householdLaunchDelegate
    
    if let topLevelNavigationController = topLevelNavigationController {
      topLevelNavigationController.push(householdSignInViewController)
    }
  }
}

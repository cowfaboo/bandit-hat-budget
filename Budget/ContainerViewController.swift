//
//  ContainerViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  
  // MARK: - Public Methods
  
  func presentSignInView() {
    
    let signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
    let navigationController = UINavigationController(rootViewController: signInViewController)
    present(navigationController, animated: true, completion: nil)
  }
  
  func presentExpenseEntryView() {
    let expenseEntryViewController = ExpenseEntryViewController(nibName: "ExpenseEntryViewController", bundle: nil)
    present(expenseEntryViewController, animated: true, completion: nil)
  }

}


//
//  BottomSlideViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-01-09.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol BottomSlideDelegate: class {
  func shouldDismissBottomSlideViewController()
}

class BottomSlideViewController: UIViewController {
  
  weak var bottomSlideDelegate: BottomSlideDelegate?
  
  @IBOutlet weak var containerView: UIView!
  
  var viewController: UIViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let viewController = viewController {
      add(viewController, to: containerView)
    }
    
    containerView.layer.cornerRadius = 8.0
    containerView.clipsToBounds = true
    
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  @IBAction func dismissButtonTapped() {
    bottomSlideDelegate?.shouldDismissBottomSlideViewController()
  }
}

extension BottomSlideViewController: ExpenseDataDelegate {
  func shouldDismissExpenseData() {
    bottomSlideDelegate?.shouldDismissBottomSlideViewController()
  }
  
  func didFinishLoadingExpenseData() {
    
  }
}

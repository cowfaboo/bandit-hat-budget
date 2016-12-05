//
//  ContainerViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController {

  @IBOutlet weak var dataNavigationContainerView: UIView!
  @IBOutlet weak var addExpenseButton: UIButton!
  
  var dataNavigationController: DataNavigationController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dataNavigationController = DataNavigationController(nibName: "DataNavigationController", bundle: nil)
    addChildViewController(dataNavigationController)
    dataNavigationController.view.frame = dataNavigationContainerView.bounds
    dataNavigationContainerView.addSubview(dataNavigationController.view)
    dataNavigationController.didMove(toParentViewController: self)
    
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }

  // MARK: - Public Methods
  
  func presentSignInView() {
    
    let signInViewController = SignInViewController(nibName: "SignInViewController", bundle: nil)
    signInViewController.signInDelegate = self
    let navigationController = UINavigationController(rootViewController: signInViewController)
    present(navigationController, animated: true, completion: nil)
  }
  
  func presentExpenseEntryView() {
    let expenseEntryViewController = ExpenseEntryViewController(nibName: "ExpenseEntryViewController", bundle: nil)
    expenseEntryViewController.expenseEntryDelegate = self
    present(expenseEntryViewController, animated: true, completion: nil)
  }
  
  func presentCategoryManagementView() {
    let categoryManagementViewController = CategoryManagementViewController(nibName: "CategoryManagementViewController", bundle: nil)
    categoryManagementViewController.categoryManagementDelegate = self
    present(categoryManagementViewController, animated: true, completion: nil)
  }
  
  // MARK: - Action Methods
  
  @IBAction func addExpenseButtonTapped() {
    self.presentExpenseEntryView()
  }
  
  @IBAction func manageCategoriesButtonTapped() {
    self.presentCategoryManagementView()
  }
}

extension ContainerViewController: SignInDelegate {
  func signInCompleted() {
    dismiss(animated: true, completion: nil)
  }
}

extension ContainerViewController: ExpenseEntryDelegate {
  func expenseEntryDismissed() {
    dismiss(animated: true, completion: nil)
  }
}

extension ContainerViewController: CategoryManagementDelegate {
  func categoryManagementDismissed() {
    dismiss(animated: true, completion: nil)
  }
}


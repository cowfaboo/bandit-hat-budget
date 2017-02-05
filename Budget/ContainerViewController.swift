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
  @IBOutlet weak var addExpenseButton: BHButton!
  @IBOutlet weak var settingsButton: BHButton!
  
  var dataNavigationController: DataNavigationController!
  var topLayerAnimator = TopLayerAnimator()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    addExpenseButton.isCircular = true
    settingsButton.isCircular = true
    
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
    navigationController.navigationBar.isHidden = true
    present(navigationController, animated: true, completion: nil)
  }
  
  func presentExpenseEntryView() {
    
    let expenseEntryViewController = ExpenseEntryViewController(nibName: "ExpenseEntryViewController", bundle: nil)
    expenseEntryViewController.interactivePresenter = self
    expenseEntryViewController.expenseEntryDelegate = self
    expenseEntryViewController.transitioningDelegate = self
    expenseEntryViewController.modalPresentationStyle = .custom
    
    topLayerAnimator.initialFrame = CGRect(x: 0, y: Utilities.screenHeight, width: Utilities.screenWidth, height: Utilities.screenHeight)
    
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
    dismiss(animated: true)
  }
}

extension ContainerViewController: ExpenseEntryDelegate {
  func expenseEntryDismissed() {
    dismiss(animated: true)
  }
  
  func expenseEntered() {
    
    if let dataViewController = dataNavigationController.currentViewController as? DataDisplaying {
      dataViewController.updateData()
    }
    
    dismiss(animated: true)
  }
}

extension ContainerViewController: CategoryManagementDelegate {
  func categoryManagementDismissed() {
    dismiss(animated: true, completion: nil)
  }
}

extension ContainerViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    topLayerAnimator.presenting = true
    return topLayerAnimator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    topLayerAnimator.presenting = false
    return topLayerAnimator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if topLayerAnimator.interactive {
      topLayerAnimator.presenting = true
      return topLayerAnimator
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if topLayerAnimator.interactive {
      topLayerAnimator.presenting = false
      return topLayerAnimator
    }
    return nil
  }
}

extension ContainerViewController: InteractivePresenter {
  
  func interactiveDismissalBegan() {
    topLayerAnimator.interactive = true
    dismiss(animated: true)
  }
  
  func interactiveDismissalChanged(withProgress progress: CGFloat) {
    topLayerAnimator.update(progress)
  }
  
  func interactiveDismissalCanceled(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat) {
    topLayerAnimator.distanceToTravel = distanceToTravel
    topLayerAnimator.velocity = velocity
    topLayerAnimator.cancel()
    topLayerAnimator.interactive = false
  }
  
  func interactiveDismissalFinished(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat) {
    topLayerAnimator.distanceToTravel = distanceToTravel
    topLayerAnimator.velocity = velocity
    topLayerAnimator.finish()
    topLayerAnimator.interactive = false
  }
}


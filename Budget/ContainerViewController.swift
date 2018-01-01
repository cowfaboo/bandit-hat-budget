//
//  ContainerViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class ContainerViewController: UIViewController, InteractivePresenter, TopLevelViewControllerDelegate {

  static let sharedInstance = ContainerViewController(nibName: "ContainerViewController", bundle: nil)
  
  @IBOutlet weak var dataNavigationContainerView: UIView!
  @IBOutlet weak var addExpenseButton: BHButton!
  @IBOutlet weak var settingsButton: BHButton!
  
  var dataNavigationController: DataNavigationController!
  var presentationAnimator: PresentationAnimator = TopLayerAnimator()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    view.clipsToBounds = true
    
    if Utilities.isIphoneX {
      view.layer.cornerRadius = 40.0
    }
    
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
  
  func presentHouseholdLaunchView() {
    
    let householdLaunchViewController = HouseholdLaunchViewController(nibName: "HouseholdLaunchViewController", bundle: nil)
    householdLaunchViewController.householdLaunchDelegate = self
    let topLevelNavigationController = TopLevelNavigationController(withRootViewController: householdLaunchViewController)
    topLevelNavigationController.topLevelViewControllerDelegate = self
    topLevelNavigationController.interactivePresenter = self
    topLevelNavigationController.transitioningDelegate = self
    topLevelNavigationController.modalPresentationStyle = .custom
    topLevelNavigationController.modalPresentationCapturesStatusBarAppearance = true
    
    presentationAnimator.initialCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight * 1.5)
    present(topLevelNavigationController, animated: true, completion: nil)
  }
  
  func presentUserClaimView() {
    
    let userClaimViewController = UserClaimViewController(nibName: "UserClaimViewController", bundle: nil)
    userClaimViewController.userClaimDelegate = self
    let navigationController = UINavigationController(rootViewController: userClaimViewController)
    navigationController.navigationBar.isHidden = true
    present(navigationController, animated: true, completion: nil)
  }
  
  func presentExpenseEntryView() {
    
    let expenseEntryViewController = ExpenseEntryViewController(nibName: "ExpenseEntryViewController", bundle: nil)
    expenseEntryViewController.interactivePresenter = self
    expenseEntryViewController.topLevelViewControllerDelegate = self
    expenseEntryViewController.expenseEntryDelegate = self
    expenseEntryViewController.transitioningDelegate = self
    expenseEntryViewController.modalPresentationStyle = .custom
    
    presentationAnimator.initialCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight * 1.5)
    
    present(expenseEntryViewController, animated: true, completion: nil)
  }
  
  func presentSettingsView() {
    
    let settingsViewController = SettingsViewController(nibName: "SettingsViewController", bundle: nil)
    settingsViewController.settingsDelegate = self
    let topLevelNavigationController = TopLevelNavigationController(withRootViewController: settingsViewController)
    topLevelNavigationController.topLevelViewControllerDelegate = self
    topLevelNavigationController.interactivePresenter = self
    topLevelNavigationController.transitioningDelegate = self
    topLevelNavigationController.modalPresentationStyle = .custom
    topLevelNavigationController.modalPresentationCapturesStatusBarAppearance = true
    
    presentationAnimator.initialCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight * 1.5)
    present(topLevelNavigationController, animated: true, completion: nil)
  }
  
  // MARK: - Action Methods
  
  @IBAction func addExpenseButtonTapped() {
    self.presentExpenseEntryView()
  }
  
  @IBAction func settingsButtonTapped() {
    self.presentSettingsView()
  }
}

extension ContainerViewController: SettingsDelegate {
  func shouldDismissSettings() {
    dismiss(animated: true)
  }
}

extension ContainerViewController: UserClaimDelegate {
  func userClaimed() {
    dismiss(animated: true)
  }
}

extension ContainerViewController: ExpenseEntryDelegate {
  
  func expenseEntered() {
    
    if let dataViewController = dataNavigationController.currentViewController as? DataDisplaying {
      dataViewController.updateData()
    }
    
    dismiss(animated: true)
  }
}

extension ContainerViewController: HouseholdLaunchDelegate {
  func householdLaunched() {
    dismiss(animated: true)
  }
}

extension ContainerViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentationAnimator.presenting = true
    return presentationAnimator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentationAnimator.presenting = false
    return presentationAnimator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if presentationAnimator.interactive {
      presentationAnimator.presenting = true
      return presentationAnimator
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if presentationAnimator.interactive {
      presentationAnimator.presenting = false
      return presentationAnimator
    }
    return nil
  }
}


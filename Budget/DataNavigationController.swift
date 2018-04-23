//
//  DataNavigationController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit
import CoreData

class DataNavigationController: UIViewController {
  
  let TransitionDistance = Utilities.screenWidth
  
  @IBOutlet weak var currentView: UIView!
  @IBOutlet weak var nextView: UIView!
  @IBOutlet weak var previousView: UIView!
  
  @IBOutlet weak var currentViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var currentViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var previousViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var previousViewTrailingConstraint: NSLayoutConstraint!
  
  @IBOutlet weak var amountsButton: BHButton!
  @IBOutlet weak var expensesButton: BHButton!
  
  var dataPresentationType = DataPresentationType.amounts {
    didSet {
      if dataPresentationType == .amounts {
        amountsButton.isHidden = true
        expensesButton.isHidden = false
      } else {
        amountsButton.isHidden = false
        expensesButton.isHidden = true
      }
    }
  }
  
  var currentViewController: (UIViewController & DataDisplaying)!
  var nextViewController: (UIViewController & DataDisplaying)?
  var previousViewController: (UIViewController & DataDisplaying)?
  
  var leftRecognizer: DirectionalPanGestureRecognizer!
  var rightRecognizer: DirectionalPanGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftRecognizer = DirectionalPanGestureRecognizer(target: self, action: #selector(handlePreviousDrag(_:)))
    leftRecognizer.gestureDirection = .Horizontal
    leftRecognizer.delegate = self
    view.addGestureRecognizer(leftRecognizer)
    
    rightRecognizer = DirectionalPanGestureRecognizer(target: self, action: #selector(handleNextDrag(_:)))
    rightRecognizer.gestureDirection = .Horizontal
    rightRecognizer.delegate = self
    view.addGestureRecognizer(rightRecognizer)
    
    
    expensesButton.isCircular = true
    amountsButton.isCircular = true
    
    let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
    amountDataViewController.startDate = Date().startAndEndOfMonth().startDate
    amountDataViewController.endDate = Date().startAndEndOfMonth().endDate
    amountDataViewController.userFilter = nil
    navigate(to: amountDataViewController)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @objc func handlePreviousDrag(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    
    if recognizer.state == .began {
      
      view.endEditing(true)
      view.isUserInteractionEnabled = false
      
      currentViewController?.view.isUserInteractionEnabled = false
      previousViewController?.view.isUserInteractionEnabled = false
      
      previousViewLeadingConstraint.constant = -TransitionDistance
      previousViewTrailingConstraint.constant = TransitionDistance
      nextViewLeadingConstraint.constant = TransitionDistance
      nextViewTrailingConstraint.constant = -TransitionDistance
      previousView.alpha = 0.25
      view.layoutIfNeeded()
      
    } else if recognizer.state == .changed {
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      
      currentViewLeadingConstraint.constant = progress * TransitionDistance
      currentViewTrailingConstraint.constant = -progress * TransitionDistance
      
      previousViewLeadingConstraint.constant = -TransitionDistance + (progress * TransitionDistance)
      previousViewTrailingConstraint.constant = TransitionDistance - (progress * TransitionDistance)
      previousView.alpha = 0.25 + progress * 0.75
      
      view.layoutIfNeeded()
      
    } else if recognizer.state == .ended {
      
      leftRecognizer.isEnabled = false
      rightRecognizer.isEnabled = false
      
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      previousViewController?.view.isUserInteractionEnabled = true
      
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      let velocity = recognizer.velocity(in: view).x
      
      if (progress > 0.5 || velocity > 300) && velocity > -300 {
        let distanceToTravel = (1.0 - progress) * TransitionDistance
        
        
        animateToPreviousView(withDistanceToTravel: distanceToTravel, andVelocity: velocity) {
          self.makePreviousDataViewCurrent()
        }
        
      } else {
        let distanceToTravel = progress * TransitionDistance
        animateToCurrentView(withDistanceToTravel: distanceToTravel, andVelocity: -velocity)
      }
      
    } else {
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      previousViewController?.view.isUserInteractionEnabled = true
    }
  }
  
  @objc func handleNextDrag(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    
    if recognizer.state == .began {
      
      view.endEditing(true)
      view.isUserInteractionEnabled = false
      
      currentViewController?.view.isUserInteractionEnabled = false
      previousViewController?.view.isUserInteractionEnabled = false
      
      nextViewLeadingConstraint.constant = TransitionDistance
      nextViewTrailingConstraint.constant = -TransitionDistance
      previousViewLeadingConstraint.constant = -TransitionDistance
      previousViewTrailingConstraint.constant = TransitionDistance
      nextView.alpha = 0.25
      view.layoutIfNeeded()
      
    } else if recognizer.state == .changed {
      var progress = recognizer.translation(in: view).x / -TransitionDistance
      progress = min(1.0, max(0.0, progress))
      
      if currentViewController?.timeRangeType == .annual {
        progress = progress / (1.0 + (progress * 4.0))
      }
      
      nextViewLeadingConstraint.constant = TransitionDistance - progress * TransitionDistance
      nextViewTrailingConstraint.constant = -TransitionDistance + progress * TransitionDistance
      currentViewLeadingConstraint.constant = -progress * TransitionDistance
      currentViewTrailingConstraint.constant = progress * TransitionDistance
      nextView.alpha = 0.25 + progress * 0.75
      
      view.layoutIfNeeded()
      
    } else if recognizer.state == .ended {
      
      leftRecognizer.isEnabled = false
      rightRecognizer.isEnabled = false
      
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      previousViewController?.view.isUserInteractionEnabled = true
      
      var progress = recognizer.translation(in: view).x / -TransitionDistance
      progress = min(1.0, max(0.0, progress))
      let oppositeProgress = 1.0 - progress
      var velocity = recognizer.velocity(in: view).x
      
      
      if currentViewController?.timeRangeType == .annual {
        progress = progress / (1.0 + (progress * 4.0))
        velocity = velocity / (1.0 + (velocity * 4.0))
        let distanceToTravel = progress * TransitionDistance
        animateToCurrentView(withDistanceToTravel: distanceToTravel, andVelocity: velocity)
        return
      }
      
      if (oppositeProgress > 0.5 || velocity > 300) && velocity > -300 {
        let distanceToTravel = (1.0 - oppositeProgress) * TransitionDistance
        
        animateToCurrentView(withDistanceToTravel: distanceToTravel, andVelocity: velocity)
        
        UIView.animate(withDuration: 0.3, delay: 0.0, options: .allowUserInteraction, animations: { () -> Void in
          self.nextView.alpha = 0.0
        }, completion: nil)
        
      } else {
        let distanceToTravel = oppositeProgress * TransitionDistance
        
        animateToNextView(withDistanceToTravel: distanceToTravel, andVelocity: -velocity) {
          self.makeNextDataViewCurrent()
        }
      }
      
    } else {
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      previousViewController?.view.isUserInteractionEnabled = true
    }
  }
  
  private func animateToNextView(withDistanceToTravel distanceToTravel: CGFloat, andVelocity velocity: CGFloat, completion: (() -> ())?) {
    self.view.layoutIfNeeded()
    nextViewLeadingConstraint.constant = 0
    nextViewTrailingConstraint.constant = 0
    currentViewLeadingConstraint.constant = -TransitionDistance
    currentViewTrailingConstraint.constant = TransitionDistance
    
    // PROBLEM: 10.99
    var springVelocity = velocity / max(distanceToTravel, 1.0)
    
    if springVelocity > 10.86 && springVelocity <= 11.0 {
      springVelocity = 10.86
    }
    
    if springVelocity > 11.0 && springVelocity < 11.14 {
      springVelocity = 11.14
    }
    
    UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      
      self.nextView.alpha = 1.0
      self.view.layoutIfNeeded()
      
    }, completion: { (finished: Bool) -> Void in
      if let completion = completion {
        completion()
      }
      self.rightRecognizer.isEnabled = true
      self.leftRecognizer.isEnabled = true
    })
  }
  
  private func animateToCurrentView(withDistanceToTravel distanceToTravel: CGFloat, andVelocity velocity: CGFloat) {
    self.view.layoutIfNeeded()
    currentViewLeadingConstraint.constant = 0
    currentViewTrailingConstraint.constant = 0
    previousViewLeadingConstraint.constant = -TransitionDistance
    previousViewTrailingConstraint.constant = TransitionDistance
    nextViewLeadingConstraint.constant = TransitionDistance
    nextViewTrailingConstraint.constant = -TransitionDistance
    
    // PROBLEM: 10.99
    var springVelocity = velocity / max(distanceToTravel, 1.0)
    
    if springVelocity > 10.86 && springVelocity <= 11.0 {
      springVelocity = 10.86
    }
    
    if springVelocity > 11.0 && springVelocity < 11.14 {
      springVelocity = 11.14
    }
    
    UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      
      self.view.layoutIfNeeded()
      
    }, completion: { (finished: Bool) -> Void in
      self.rightRecognizer.isEnabled = true
      self.leftRecognizer.isEnabled = true
    })
  }
  
  private func animateToPreviousView(withDistanceToTravel distanceToTravel: CGFloat, andVelocity velocity: CGFloat, completion: (() -> ())?) {
    
    currentViewTrailingConstraint.constant = -TransitionDistance
    currentViewLeadingConstraint.constant = TransitionDistance
    previousViewTrailingConstraint.constant = 0
    previousViewLeadingConstraint.constant = 0
    
    //PROBLEM: 10.99
    var springVelocity = velocity / max(distanceToTravel, 1.0)
    
    if springVelocity > 10.86 && springVelocity <= 11.0 {
      springVelocity = 10.86
    }
    
    if springVelocity > 11.0 && springVelocity < 11.14 {
      springVelocity = 11.14
    }
    
    UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      self.view.layoutIfNeeded()
      
      self.previousView.alpha = 1.0
      
    }, completion: { (finished: Bool) -> Void in
      if let completion = completion {
        completion()
      }
      self.rightRecognizer.isEnabled = true
      self.leftRecognizer.isEnabled = true
    })
  }
  
  @IBAction func expensesButtonTapped() {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    
    expenseDataViewController.userFilter = currentViewController.userFilter
    expenseDataViewController.startDate = currentViewController.startDate
    expenseDataViewController.endDate = currentViewController.endDate
    
    self.dataPresentationType = .expenses
    self.navigate(to: expenseDataViewController, withAnimatedTransition: true)
  }
  
  @IBAction func amountsButtonTapped() {
    
    let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
    amountDataViewController.startDate = currentViewController.startDate
    amountDataViewController.endDate = currentViewController.endDate
    amountDataViewController.userFilter = currentViewController.userFilter
    
    self.dataPresentationType = .amounts
    self.navigate(to: amountDataViewController, withAnimatedTransition: false)
  }
  
  func buildPreviousDataViewController() {
    
    let dates: (startDate: Date, endDate: Date)
    
    if currentViewController.timeRangeType == .annual {
      dates = Date().startAndEndOfMonth()
    } else {
      dates = currentViewController.startDate.startOfPreviousMonth().startAndEndOfMonth()
    }
    
    if dataPresentationType == .amounts {
      
      let amountDataViewController: AmountDataViewController = (self.previousViewController as? AmountDataViewController) ?? AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
      amountDataViewController.startDate = dates.startDate
      amountDataViewController.endDate = dates.endDate
      amountDataViewController.userFilter = currentViewController.userFilter
      amountDataViewController.updateData()
      if let previousViewController = previousViewController {
        previousViewController.removeFromContainerView()
      }
      
      previousViewController = amountDataViewController
      add(amountDataViewController, to: previousView)
      
    } else {
      
      let expenseDataViewController = ((self.previousViewController as? ExpenseDataViewController) ?? ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil))
      expenseDataViewController.startDate = dates.startDate
      expenseDataViewController.endDate = dates.endDate
      expenseDataViewController.userFilter = currentViewController.userFilter
      expenseDataViewController.updateData()
      if let previousViewController = previousViewController {
        previousViewController.removeFromContainerView()
      }
      
      previousViewController = expenseDataViewController
      add(previousViewController!, to: previousView)
    }
    
    previousViewController?.scrollToTop()
  }
  
  func buildNextDataViewController() {
    
    let nextDate = currentViewController.endDate.startOfNextMonth()
    
    if nextDate > Date() {
      
      let dates = currentViewController.startDate.startAndEndOfYear()
      
      if dataPresentationType == .amounts {
        
        let amountDataViewController = (self.nextViewController as? AmountDataViewController) ?? AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
        amountDataViewController.startDate = dates.startDate
        amountDataViewController.endDate = dates.endDate
        amountDataViewController.userFilter = currentViewController.userFilter
        amountDataViewController.updateData()
        if let nextViewController = nextViewController {
          nextViewController.removeFromContainerView()
        }
        
        nextViewController = amountDataViewController
        add(nextViewController!, to: nextView)
        
      } else {
        
        let expenseDataViewController = (self.nextViewController as? ExpenseDataViewController) ?? ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
        expenseDataViewController.startDate = dates.startDate
        expenseDataViewController.endDate = dates.endDate
        expenseDataViewController.userFilter = currentViewController.userFilter
        expenseDataViewController.updateData()
        if let nextViewController = nextViewController {
          nextViewController.removeFromContainerView()
        }
        
        nextViewController = expenseDataViewController
        add(nextViewController!, to: nextView)
      }
      
    } else {
      
      let dates = currentViewController.startDate.startOfNextMonth().startAndEndOfMonth()
      
      if dataPresentationType == .amounts {
        
        let amountDataViewController = (self.nextViewController as? AmountDataViewController) ?? AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
        amountDataViewController.startDate = dates.startDate
        amountDataViewController.endDate = dates.endDate
        amountDataViewController.userFilter = currentViewController.userFilter
        amountDataViewController.updateData()
        if let nextViewController = nextViewController {
          nextViewController.removeFromContainerView()
        }
        
        nextViewController = amountDataViewController
        add(nextViewController!, to: nextView)
        
      } else {
        
        let expenseDataViewController = (self.nextViewController as? ExpenseDataViewController) ?? ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
        expenseDataViewController.startDate = dates.startDate
        expenseDataViewController.endDate = dates.endDate
        expenseDataViewController.userFilter = currentViewController.userFilter
        expenseDataViewController.updateData()
        if let nextViewController = nextViewController {
          nextViewController.removeFromContainerView()
        }
        
        nextViewController = expenseDataViewController
        add(nextViewController!, to: nextView)
      }
    }
    nextViewController?.scrollToTop()
  }
  
  func navigate(to viewController: (UIViewController & DataDisplaying), withAnimatedTransition shouldAnimateTransition: Bool = false) {
    
    if let currentViewController = currentViewController {
      currentViewController.removeFromContainerView()
    }
    
    currentViewController = viewController
    add(currentViewController, to: currentView, withAnimatedTransition: shouldAnimateTransition)
    
    nextViewController?.removeFromContainerView()
    previousViewController?.removeFromContainerView()
    nextViewController = nil
    previousViewController = nil
    buildNextDataViewController()
    buildPreviousDataViewController()
  }
  
  func repositionViews() {
    
    currentViewLeadingConstraint.constant = 0
    currentViewTrailingConstraint.constant = 0
    previousViewLeadingConstraint.constant = -TransitionDistance
    previousViewTrailingConstraint.constant = TransitionDistance
    nextViewLeadingConstraint.constant = TransitionDistance
    nextViewTrailingConstraint.constant = -TransitionDistance
    
    view.layoutIfNeeded()
  }
  
  func makeNextDataViewCurrent() {
    
    if let currentViewController = currentViewController {
      currentViewController.removeFromContainerView()
    }
    
    swap(&currentViewController!, &nextViewController!)
    add(currentViewController, to: currentView)
    repositionViews()
    
    buildNextDataViewController()
    buildPreviousDataViewController()
  }
  
  func makePreviousDataViewCurrent() {
    
    if let currentViewController = currentViewController {
      currentViewController.removeFromContainerView()
    }
    
    swap(&currentViewController!, &previousViewController!)
    add(currentViewController, to: currentView)
    repositionViews()
    
    buildNextDataViewController()
    buildPreviousDataViewController()
  }
}

extension DataNavigationController: UIGestureRecognizerDelegate {
  
  func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    let gestureRecognizer = gestureRecognizer as! DirectionalPanGestureRecognizer
    if gestureRecognizer == leftRecognizer && gestureRecognizer.velocity(in: view).x > 0 {
      return true
    } else if gestureRecognizer == rightRecognizer && gestureRecognizer.velocity(in: view).x < 0 {
      return true
    } else {
      return false
    }
  }
}

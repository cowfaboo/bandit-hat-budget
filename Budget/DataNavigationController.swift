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
  
  @IBOutlet weak var nextDummyHeaderView: UIView!
  @IBOutlet weak var previousDummyHeaderView: UIView!
  
  @IBOutlet weak var nextDummyScrollView: UIScrollView!
  @IBOutlet weak var previousDummyScrollView: UIScrollView!
  var previousDummyAmountWidgetArray = [AmountWidgetViewController]()
  var previousDummyContainerViewArray = [UIView]()
  var nextDummyAmountWidgetArray = [AmountWidgetViewController]()
  var nextDummyContainerViewArray = [UIView]()
  
  @IBOutlet weak var currentViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var currentViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var previousViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var previousViewTrailingConstraint: NSLayoutConstraint!
  
  var nextDataHeaderViewController: DataHeaderViewController!
  var previousDataHeaderViewController: DataHeaderViewController!
  
  @IBOutlet weak var amountsButton: BHButton!
  @IBOutlet weak var expensesButton: BHButton!
  
  var currentDate = Date().startAndEndOfMonth().startDate
  var currentUser: BKUser? {
    didSet {
      if let currentViewController = currentViewController as? DataDisplaying {
        currentViewController.userFilter = currentUser
      }
    }
  }
  
  var timeRangeType = TimeRangeType.monthly
  
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
  
  var currentViewController: UIViewController!
  var nextViewController: UIViewController!
  var previousViewController: UIViewController!
  
  var leftRecognizer: DirectionalPanGestureRecognizer!
  var rightRecognizer: DirectionalPanGestureRecognizer!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftRecognizer = DirectionalPanGestureRecognizer(target: self, action: #selector(handlePreviousDrag(_:)))
    leftRecognizer.gestureDirection = .StrictHorizontal
    leftRecognizer.delegate = self
    view.addGestureRecognizer(leftRecognizer)
    
    rightRecognizer = DirectionalPanGestureRecognizer(target: self, action: #selector(handleNextDrag(_:)))
    rightRecognizer.gestureDirection = .StrictHorizontal
    rightRecognizer.delegate = self
    view.addGestureRecognizer(rightRecognizer)
    
    
    expensesButton.isCircular = true
    amountsButton.isCircular = true
    
    let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
    amountDataViewController.date = currentDate
    amountDataViewController.timeRangeType = .monthly
    amountDataViewController.userFilter = currentUser
    navigate(to: amountDataViewController)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func handlePreviousDrag(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    
    if recognizer.state == .began {
      
      buildDummyPreviousView()
      
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
      
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      previousViewController?.view.isUserInteractionEnabled = true
      
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      let velocity = recognizer.velocity(in: view).x
      
      if (progress > 0.5 || velocity > 300) && velocity > -300 {
        let distanceToTravel = (1.0 - progress) * TransitionDistance
        
        
        animateToPreviousView(withDistanceToTravel: distanceToTravel, andVelocity: velocity) {
          self.buildPreviousDataViewController()
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
  
  func handleNextDrag(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    
    if recognizer.state == .began {
      
      buildDummyNextView()
      
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
      
      if timeRangeType == .annual {
        progress = progress / (1.0 + (progress * 4.0))
      }
      
      nextViewLeadingConstraint.constant = TransitionDistance - progress * TransitionDistance
      nextViewTrailingConstraint.constant = -TransitionDistance + progress * TransitionDistance
      currentViewLeadingConstraint.constant = -progress * TransitionDistance
      currentViewTrailingConstraint.constant = progress * TransitionDistance
      nextView.alpha = 0.25 + progress * 0.75
      
      view.layoutIfNeeded()
      
    } else if recognizer.state == .ended {
      
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      previousViewController?.view.isUserInteractionEnabled = true
      
      var progress = recognizer.translation(in: view).x / -TransitionDistance
      progress = min(1.0, max(0.0, progress))
      let oppositeProgress = 1.0 - progress
      var velocity = recognizer.velocity(in: view).x
      
      
      if timeRangeType == .annual {
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
          self.buildNextDataViewController()
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
    })
  }
  
  @IBAction func expensesButtonTapped() {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    
    expenseDataViewController.date = currentDate
    expenseDataViewController.userFilter = currentUser
    expenseDataViewController.timeRangeType = timeRangeType
    
    if let dataDisplayingViewController = currentViewController as? DataDisplaying {
      dataDisplayingViewController.fadeOut() {
        self.navigate(to: expenseDataViewController, withAnimatedTransition: true)
        self.dataPresentationType = .expenses
      }
    } else {
      self.navigate(to: expenseDataViewController, withAnimatedTransition: true)
      self.dataPresentationType = .expenses
    }
  }
  
  @IBAction func amountsButtonTapped() {
    
    let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
    amountDataViewController.date = currentDate
    amountDataViewController.userFilter = currentUser
    amountDataViewController.timeRangeType = timeRangeType
    
    if let dataDisplayingViewController = currentViewController as? DataDisplaying {
      dataDisplayingViewController.fadeOut() {
        self.navigate(to: amountDataViewController, withAnimatedTransition: true)
        self.dataPresentationType = .amounts
      }
    } else {
      self.navigate(to: amountDataViewController, withAnimatedTransition: true)
      self.dataPresentationType = .amounts
    }
  }
  
  func buildDummyPreviousView() {
    
    let previousDate: Date
    
    if timeRangeType == .monthly {
      previousDate = currentDate.startOfPreviousMonth()
    } else {
      previousDate = currentDate
    }
    
    if let previousDataHeaderViewController = previousDataHeaderViewController {
      previousDataHeaderViewController.removeFromContainerView()
    }
    
    previousDataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
    previousDataHeaderViewController.date = previousDate
    previousDataHeaderViewController.user = currentUser
    previousDataHeaderViewController.timeRangeType = .monthly
    add(previousDataHeaderViewController, to: previousDummyHeaderView)
    
    if dataPresentationType == .amounts {
      previousDummyScrollView.isHidden = false
      updatePreviousDummyDataViews()
    } else {
      previousDummyScrollView.isHidden = true
    }
  }
  
  func buildDummyNextView() {
    
    var nextDate = currentDate.startOfNextMonth()
    let nextTimeRangeType: TimeRangeType
    
    if nextDate > Date() {
      nextTimeRangeType = .annual
      nextDate = currentDate
    } else {
      nextTimeRangeType = .monthly
    }
    
    if let nextDataHeaderViewController = nextDataHeaderViewController {
      nextDataHeaderViewController.removeFromContainerView()
    }
    
    nextDataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
    nextDataHeaderViewController.date = nextDate
    nextDataHeaderViewController.user = currentUser
    nextDataHeaderViewController.timeRangeType = nextTimeRangeType
    add(nextDataHeaderViewController, to: nextDummyHeaderView)
    
    if dataPresentationType == .amounts {
      nextDummyScrollView.isHidden = false
      updateNextDummyDataViews()
    } else {
      nextDummyScrollView.isHidden = true
    }
  }
  
  func buildPreviousDataViewController() {
    
    if timeRangeType == .monthly {
      currentDate = currentDate.startOfPreviousMonth()
    } else {
      timeRangeType = .monthly
    }
    
    if dataPresentationType == .amounts {
      
      let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
      amountDataViewController.date = currentDate
      amountDataViewController.userFilter = currentUser
      amountDataViewController.amountDataDelegate = self
      navigate(to: amountDataViewController)
      
    } else {
      
      let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
      expenseDataViewController.date = currentDate
      expenseDataViewController.userFilter = currentUser
      expenseDataViewController.expenseDataDelegate = self
      navigate(to: expenseDataViewController)
    }
  }
  
  func buildNextDataViewController() {
    
    let nextDate = currentDate.startOfNextMonth()
    
    if nextDate > Date() {
      
      if dataPresentationType == .amounts {
        
        let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
        amountDataViewController.timeRangeType = .annual
        amountDataViewController.userFilter = currentUser
        amountDataViewController.amountDataDelegate = self
        navigate(to: amountDataViewController)
        
      } else {
        
        let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
        expenseDataViewController.timeRangeType = .annual
        expenseDataViewController.userFilter = currentUser
        expenseDataViewController.expenseDataDelegate = self
        navigate(to: expenseDataViewController)
      }
      
      timeRangeType = .annual
      
    } else {
      
      currentDate = nextDate
      
      if dataPresentationType == .amounts {
        
        let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
        amountDataViewController.date = currentDate
        amountDataViewController.userFilter = currentUser
        amountDataViewController.amountDataDelegate = self
        navigate(to: amountDataViewController)
        
      } else {
        
        let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
        expenseDataViewController.date = currentDate
        expenseDataViewController.userFilter = currentUser
        expenseDataViewController.expenseDataDelegate = self
        navigate(to: expenseDataViewController)
      }
      
      timeRangeType = .monthly
    }
  }
  
  func navigate(to viewController: UIViewController, withAnimatedTransition shouldAnimateTransition: Bool = false) {
    
    if let currentViewController = currentViewController {
      currentViewController.removeFromContainerView()
    }
    
    currentViewController = viewController
    add(currentViewController, to: currentView, withAnimatedTransition: shouldAnimateTransition)
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
  
  func updatePreviousDummyDataViews() {
    
    let amountDataViewController = (currentViewController as! AmountDataViewController)
    let amountArray = amountDataViewController.amountArray
    
    if (amountArray.count == previousDummyContainerViewArray.count) {
      return
    }
    
    let completionPercentage: Float = 0
    
    for amountWidget in previousDummyAmountWidgetArray {
      amountWidget.removeFromContainerView()
    }
    
    for containerView in previousDummyContainerViewArray {
      containerView.removeFromSuperview()
    }
    
    previousDummyAmountWidgetArray = []
    previousDummyContainerViewArray = []
    
    let containerWidth: CGFloat = 136
    let containerHeight: CGFloat = 200
    let remainingWidthSpacing = Utilities.screenWidth - containerWidth * 2
    var currentYPosition: CGFloat = 0
    
    var index = 0
    for amount in amountArray {
      
      let currentXPosition: CGFloat
      if index % 2 == 0 {
        currentXPosition = remainingWidthSpacing / 3
      } else {
        currentXPosition = ((remainingWidthSpacing / 3) * 2) + containerWidth
      }
      
      let containerView = UIView(frame: CGRect(x: currentXPosition, y: currentYPosition, width: containerWidth, height: containerHeight))
      previousDummyContainerViewArray.append(containerView)
      previousDummyScrollView.addSubview(containerView)
      
      let amountWidgetViewController = AmountWidgetViewController(withAmount: amount, timeRangeType: timeRangeType, completionPercentage: completionPercentage, isPlaceholder: true)
      add(amountWidgetViewController, to: containerView)
      amountWidgetViewController.refreshView()
      previousDummyAmountWidgetArray.append(amountWidgetViewController)
      
      if index % 2 == 1 {
        currentYPosition += containerHeight + 28
      }
      
      index += 1
    }
    
    let numberOfRows: Int
    if amountArray.count % 2 == 0 {
      numberOfRows = amountArray.count / 2
    } else {
      numberOfRows = amountArray.count / 2 + 1
    }
    
    previousDummyScrollView.contentSize = CGSize(width: Utilities.screenWidth, height: (containerHeight * CGFloat(numberOfRows)) + (28 * CGFloat(numberOfRows)) + 60)
    
  }
  
  func updateNextDummyDataViews() {
    
    let amountDataViewController = (currentViewController as! AmountDataViewController)
    let amountArray = amountDataViewController.amountArray
    
    if (amountArray.count == nextDummyContainerViewArray.count) {
      return
    }
    
    let completionPercentage: Float = 0
    
    for amountWidget in nextDummyAmountWidgetArray {
      amountWidget.removeFromContainerView()
    }
    
    for containerView in nextDummyContainerViewArray {
      containerView.removeFromSuperview()
    }
    
    nextDummyAmountWidgetArray = []
    nextDummyContainerViewArray = []
    
    let containerWidth: CGFloat = 136
    let containerHeight: CGFloat = 200
    let remainingWidthSpacing = Utilities.screenWidth - containerWidth * 2
    var currentYPosition: CGFloat = 0
    
    var index = 0
    for amount in amountArray {
      let currentXPosition: CGFloat
      if index % 2 == 0 {
        currentXPosition = remainingWidthSpacing / 3
      } else {
        currentXPosition = ((remainingWidthSpacing / 3) * 2) + containerWidth
      }
      
      let containerView = UIView(frame: CGRect(x: currentXPosition, y: currentYPosition, width: containerWidth, height: containerHeight))
      nextDummyContainerViewArray.append(containerView)
      nextDummyScrollView.addSubview(containerView)
      
      let amountWidgetViewController = AmountWidgetViewController(withAmount: amount, timeRangeType: timeRangeType, completionPercentage: completionPercentage, isPlaceholder: true)
      add(amountWidgetViewController, to: containerView)
      amountWidgetViewController.refreshView()
      nextDummyAmountWidgetArray.append(amountWidgetViewController)
      
      if index % 2 == 1 {
        currentYPosition += containerHeight + 28
      }
      
      index += 1
    }
    
    let numberOfRows: Int
    if amountArray.count % 2 == 0 {
      numberOfRows = amountArray.count / 2
    } else {
      numberOfRows = amountArray.count / 2 + 1
    }
    
    nextDummyScrollView.contentSize = CGSize(width: Utilities.screenWidth, height: (containerHeight * CGFloat(numberOfRows)) + (28 * CGFloat(numberOfRows)) + 60) 
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


// MARK: - Amount Data Delegate Methods
extension DataNavigationController: AmountDataDelegate {
  
  func didFinishLoadingAmountData() {
    repositionViews()
  }
  
  func shouldFilterByUser(_ user: BKUser?) {
    currentUser = user
  }
}

// MARK: - Expense Data Delegate Methods
extension DataNavigationController: ExpenseDataDelegate {
  
  func shouldDismissExpenseData() {
    
  }
  
  func didFinishLoadingExpenseData() {
    repositionViews()
  }
}

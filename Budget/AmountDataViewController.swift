//
//  AmountDataViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class AmountDataViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = BottomSlideAnimator()
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var dataScrollView: UIScrollView!
  
  var dataHeaderViewController: DataHeaderViewController?
  
  var amountWidgetArray = [AmountWidgetViewController]()
  var containerViewArray = [UIView]()
  var amountArray = [BKAmount]()
  var userFilter: BKUser? {
    didSet {
      if viewIsLoaded {
        dataHeaderViewController?.user = userFilter
        updateData(withAnimation: false)
      }
    }
  }
  var startDate: Date = Date().startAndEndOfMonth().startDate
  var endDate: Date = Date().startAndEndOfMonth().endDate
  
  var viewIsLoaded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(receiveUpdateDataViewNotification), name: .updateDataView, object: nil)
    
    dataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
    dataHeaderViewController!.date = startDate
    dataHeaderViewController!.timeRangeType = timeRangeType
    dataHeaderViewController!.user = userFilter
    add(dataHeaderViewController!, to: headerView)
    
    updateData()
    
    viewIsLoaded = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @objc func receiveUpdateDataViewNotification() {
    updateData(withAnimation: true)
  }
  
  func updateData(withAnimation animationEnabled: Bool = false) {
    
    dataHeaderViewController?.update(withDate: startDate, timeRangeType: timeRangeType, user: userFilter)
    BKAmount.getAmountsByCategory(forUser: self.userFilter, startDate: self.startDate, endDate: self.endDate, completion: { (amounts) in
      self.amountArray = amounts
      self.reloadDataViews(withAnimation: animationEnabled)
    })
  }
  
  func reloadDataViews(withAnimation animationEnabled: Bool) {
    if (amountArray.count != containerViewArray.count) {
      resetDataViews()
    }
    
    var index = 0
    for amountWidget in amountWidgetArray {
      amountWidget.amount = amountArray[index]
      amountWidget.timeRangeType = timeRangeType
      
      let completionPercentage: Float
      if (timeRangeType == .monthly && startDate.isMonthEqualTo(Date())) {
        completionPercentage = Date().completionPercentageOfMonth()
      } else if (timeRangeType == .annual && startDate.isYearEqualTo(Date())) {
        completionPercentage = Date().completionPercentageOfYear()
      } else {
        completionPercentage = 0
      }
      
      amountWidget.completionPercentage = completionPercentage
      amountWidget.refreshView(withAnimation: animationEnabled)
      index += 1
    }
    
    fadeIn(completion: nil)
  }
  
  func resetDataViews() {
    
    self.dataScrollView.alpha = 0.0
    
    let completionPercentage: Float
    if (timeRangeType == .monthly && startDate.isMonthEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfMonth()
    } else if (timeRangeType == .annual && startDate.isYearEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfYear()
    } else {
      completionPercentage = 0
    }
    
    for amountWidget in amountWidgetArray {
      amountWidget.removeFromContainerView()
    }
    
    for containerView in containerViewArray {
      containerView.removeFromSuperview()
    }
    
    amountWidgetArray = []
    containerViewArray = []
    
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
      containerViewArray.append(containerView)
      dataScrollView.addSubview(containerView)
      
      let amountWidgetViewController = AmountWidgetViewController(withAmount: amount, timeRangeType: timeRangeType, completionPercentage: completionPercentage)
      amountWidgetViewController.amountWidgetDelegate = self
      add(amountWidgetViewController, to: containerView)
      amountWidgetViewController.refreshView(withAnimation: false)
      amountWidgetArray.append(amountWidgetViewController)
      
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
    
    dataScrollView.contentSize = CGSize(width: Utilities.screenWidth, height: (containerHeight * CGFloat(numberOfRows)) + (28 * CGFloat(numberOfRows)) + 60)
    
  }
  
  // MARK: - Action Methods
  func amountViewTapped(amount: BKAmount) {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    expenseDataViewController.startDate = startDate
    expenseDataViewController.endDate = endDate
    expenseDataViewController.userFilter = userFilter
    expenseDataViewController.shouldIncludeDataHeader = false
    expenseDataViewController.expenseDataDelegate = self
    
    if let categoryID = amount.categoryID {
      if let category = BKCategory.fetchCategory(withCloudID: categoryID) {
        expenseDataViewController.category = category
      }
    }
    
    let bottomSlideViewController = BottomSlideViewController(presenting: expenseDataViewController, from: self)
    present(bottomSlideViewController, animated: true, completion: nil)
  }
}

// MARK: - Data Displaying Protocol Methods
extension AmountDataViewController: DataDisplaying {
  
  func fadeOut(completion: (() -> ())?) {
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
      self.dataScrollView.alpha = 0.0
    }) { (success) in
      if let completion = completion {
        completion()
      }
    }
  }
  
  func fadeIn(completion: (() -> ())?) {
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
      self.dataScrollView.alpha = 1.0
    }) { (success) in
      if let completion = completion {
        completion()
      }
    }
  }
  
  func scrollToTop() {
    dataScrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
  }
}

// MARK: - Amount Widget Delegate Methods
extension AmountDataViewController: AmountWidgetDelegate {
  func didSelect(category: BKCategory) {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    expenseDataViewController.startDate = startDate
    expenseDataViewController.endDate = endDate
    expenseDataViewController.userFilter = userFilter
    expenseDataViewController.shouldIncludeDataHeader = false
    expenseDataViewController.expenseDataDelegate = self
    expenseDataViewController.category = category
    
    let bottomSlideViewController = BottomSlideViewController(presenting: expenseDataViewController, from: self)
    present(bottomSlideViewController, animated: true, completion: nil)
  }
}

// MARK: - Bottom Slide Delegate Methods
extension AmountDataViewController: BottomSlideDelegate {
  
  func shouldDismissBottomSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Expense Data Delegate Methods
extension AmountDataViewController: ExpenseDataDelegate {

  func shouldDismissExpenseData() {
    dismiss(animated: true, completion: nil)
  }
  
  func didFinishLoadingExpenseData() {
    
  }
}


// MARK: - View Controller Transitioning Delegate Methods
extension AmountDataViewController: UIViewControllerTransitioningDelegate {
  
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

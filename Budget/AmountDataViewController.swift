//
//  AmountDataViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol AmountDataDelegate: class {
  func didFinishLoadingAmountData()
  func shouldFilterByUser(_ user: BKUser?)
}

class AmountDataViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = BottomSlideAnimator()
  
  weak var amountDataDelegate: AmountDataDelegate?
  
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var dataScrollView: UIScrollView!
  
  
  var dataHeaderViewController: DataHeaderViewController?
  
  var amountWidgetArray = [AmountWidgetViewController]()
  var containerViewArray = [UIView]()
  var amountArray = [BKAmount]()
  var date: Date = Date()
  var userFilter: BKUser? {
    didSet {
      if viewIsLoaded {
        dataHeaderViewController?.user = userFilter
        updateData()
      }
    }
  }
  var timeRangeType: TimeRangeType = .monthly
  
  var viewIsLoaded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .updateDataView, object: nil)
    
    dataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
    dataHeaderViewController!.date = date
    dataHeaderViewController!.timeRangeType = timeRangeType
    dataHeaderViewController!.user = userFilter
    add(dataHeaderViewController!, to: headerView)
    
    updateData()
    
    viewIsLoaded = true
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func updateDataViews() {
    if (amountArray.count != containerViewArray.count) {
      resetDataViews()
    }
    
    var index = 0
    for amountWidget in amountWidgetArray {
      if amountWidget.amount.amount != amountArray[index].amount || amountWidget.amount.categoryID != amountArray[index].categoryID {
        amountWidget.amount = amountArray[index]
        amountWidget.refreshView()
      }
      index += 1
    }
  }
  
  func resetDataViews() {
    
    let completionPercentage: Float
    if (timeRangeType == .monthly && date.isMonthEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfMonth()
    } else if (timeRangeType == .annual && date.isYearEqualTo(Date())) {
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
      amountWidgetViewController.refreshView()
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
    expenseDataViewController.date = date
    expenseDataViewController.userFilter = userFilter
    expenseDataViewController.timeRangeType = timeRangeType
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
  
  @objc func updateData() {
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = date.startAndEndOfMonth()
    } else {
      dates = date.startAndEndOfYear()
    }
    
    BKSharedBasicRequestClient.getCategories { (success, categoryArray) in
      
      guard success, categoryArray != nil else {
        print("failed to get categories")
        return
      }
      
      BKSharedBasicRequestClient.getAmountsByCategory(forUserID: self.userFilter?.cloudID, startDate: dates.startDate, endDate: dates.endDate) { (success, amountArray) in
        
        guard success, let amountArray = amountArray else {
          print("failed to get amounts")
          return
        }
        
        self.amountArray = amountArray
        self.updateDataViews()
        self.amountDataDelegate?.didFinishLoadingAmountData()
      }
    }
  }
  
  func fadeOut(completion: (() -> ())?) {
    dataScrollView.alpha = 1.0
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
      self.dataScrollView.alpha = 0.0
    }) { (success) in
      if let completion = completion {
        completion()
      }
    }
  }
  
  func fadeIn(completion: (() -> ())?) {
    dataScrollView.alpha = 0.0
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
      self.dataScrollView.alpha = 1.0
    }) { (success) in
      if let completion = completion {
        completion()
      }
    }
  }
}

// MARK: - Amount Widget Delegate Methods
extension AmountDataViewController: AmountWidgetDelegate {
  func didSelect(category: BKCategory) {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    expenseDataViewController.date = date
    expenseDataViewController.userFilter = userFilter
    expenseDataViewController.timeRangeType = timeRangeType
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

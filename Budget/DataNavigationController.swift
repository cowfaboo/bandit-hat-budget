//
//  DataNavigationController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class DataNavigationController: UIViewController {
  
  @IBOutlet weak var currentView: UIView!
  
  @IBOutlet weak var previousButton: UIButton!
  @IBOutlet weak var nextButton: UIButton!
  @IBOutlet weak var amountsButton: UIButton!
  @IBOutlet weak var expensesButton: UIButton!
  
  var currentDate = Utilities.getStartAndEndOfMonth(from: Date()).startDate
  
  var timeRangeType = TimeRangeType.monthly {
    didSet {
      if timeRangeType == .monthly {
        previousButton.isHidden = false
        nextButton.isHidden = false
      } else {
        previousButton.isHidden = false
        nextButton.isHidden = true
      }
    }
  }
  
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
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
    amountDataViewController.date = currentDate
    amountDataViewController.timeRangeType = .monthly
    navigate(to: amountDataViewController)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func expensesButtonTapped() {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .annual {
      dates = Utilities.getStartAndEndOfYear(from: currentDate)
    } else {
      dates = Utilities.getStartAndEndOfMonth(from: currentDate)
    }
    expenseDataViewController.startDate = dates.startDate
    expenseDataViewController.endDate = dates.endDate
    navigate(to: expenseDataViewController)
    dataPresentationType = .expenses
  }
  
  @IBAction func amountsButtonTapped() {
    
    let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
    amountDataViewController.date = currentDate
    navigate(to: amountDataViewController)
    dataPresentationType = .amounts
  }
  
  @IBAction func previousButtonTapped() {
    
    if timeRangeType == .monthly {
      currentDate = Utilities.getStartOfPreviousMonth(from: currentDate)
    } else {
      timeRangeType = .monthly
    }
    
    if dataPresentationType == .amounts {
      
      let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
      amountDataViewController.date = currentDate
      navigate(to: amountDataViewController)
      
    } else {
      
      let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
      let dates = Utilities.getStartAndEndOfMonth(from: currentDate)
      expenseDataViewController.startDate = dates.startDate
      expenseDataViewController.endDate = dates.endDate
      navigate(to: expenseDataViewController)
    }
  }
  
  @IBAction func nextButtonTapped() {
    
    let nextDate = Utilities.getStartOfNextMonth(from: currentDate)
    
    if nextDate > Date() {
      
      if dataPresentationType == .amounts {
        
        let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
        amountDataViewController.timeRangeType = .annual
        navigate(to: amountDataViewController)
        
      } else {
        
        let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
        let dates = Utilities.getStartAndEndOfYear(from: currentDate)
        expenseDataViewController.startDate = dates.startDate
        expenseDataViewController.endDate = dates.endDate
        navigate(to: expenseDataViewController)
      }
      
      timeRangeType = .annual
      
    } else {
      
      currentDate = nextDate
      
      if dataPresentationType == .amounts {
        
        let amountDataViewController = AmountDataViewController(nibName: "AmountDataViewController", bundle: nil)
        amountDataViewController.date = currentDate
        navigate(to: amountDataViewController)
        
      } else {
        
        let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
        let dates = Utilities.getStartAndEndOfMonth(from: currentDate)
        expenseDataViewController.startDate = dates.startDate
        expenseDataViewController.endDate = dates.endDate
        navigate(to: expenseDataViewController)
      }
      
      timeRangeType = .monthly
    }
  }
  
  func navigate(to viewController: UIViewController) {
    
    if let currentViewController = currentViewController {
      currentViewController.willMove(toParentViewController: nil)
      currentViewController.removeFromParentViewController()
      currentViewController.view.removeFromSuperview()
    }
    
    currentViewController = viewController
    addChildViewController(currentViewController)
    currentViewController.view.frame = currentView.bounds
    currentView.addSubview(currentViewController.view)
    currentViewController.didMove(toParentViewController: self)
  }
}

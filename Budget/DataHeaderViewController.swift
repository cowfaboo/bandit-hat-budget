//
//  DataHeaderViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-18.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class DataHeaderViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  var date: Date = Date() {
    didSet {
      if viewIsLoaded {
        if timeRangeType == .monthly {
          dateLabel.text = date.monthYearString()
        } else {
          dateLabel.text = date.yearString()
        }
      }
    }
  }
  
  var user: BKUser? {
    didSet {
      if viewIsLoaded {
        if let user = user {
          filterButton?.setTitle(user.name ?? "", for: .normal)
        } else {
          filterButton?.setTitle("Everyone", for: .normal)
        }
      }
    }
  }
  var timeRangeType: TimeRangeType = .monthly {
    didSet {
      if viewIsLoaded {
        if timeRangeType == .monthly {
          dateLabel.text = date.monthYearString()
        } else {
          dateLabel.text = date.yearString()
        }
      }
    }
  }
  
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var filterButton: BHButton!
  @IBOutlet weak var overallAmountPieView: AmountPieView!
  var overallAmount: BKAmount!
  var viewIsLoaded: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if timeRangeType == .monthly {
      dateLabel.text = date.monthYearString()
    } else {
      dateLabel.text = date.yearString()
    }
    
    dateLabel.textColor = UIColor.text
    filterButton.themeColor = UIColor.text
    filterButton.isCircular = true
    filterButton.isPrimaryAction = false
    
    if let user = user {
      filterButton.setTitle(user.name ?? "", for: .normal)
    }
    
    self.overallAmountPieView.alpha = 0.0
    
    viewIsLoaded = true
  }
  
  func update(withDate date: Date, timeRangeType: TimeRangeType, user: BKUser?, animation: Bool) {
    
    self.timeRangeType = timeRangeType
    self.date = date
    self.user = user
    
    let startDate: Date
    let endDate: Date
    if timeRangeType == .monthly {
      startDate = date.startAndEndOfMonth().startDate
      endDate = date.startAndEndOfMonth().endDate
    } else {
      startDate = date.startAndEndOfYear().startDate
      endDate = date.startAndEndOfYear().endDate
    }
    
    BKAmount.getAmount(forUser: user, startDate: startDate, endDate: endDate) { (amount) in
      self.overallAmount = amount
      self.reloadOverallAmountDataView(withAnimation: animation)
    }
  }
  
  func reloadOverallAmountDataView(withAnimation animationEnabled: Bool) {
    
    let completionPercentage: Float
    if (timeRangeType == .monthly && date.isMonthEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfMonth()
    } else if (timeRangeType == .annual && date.isYearEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfYear()
    } else {
      completionPercentage = 0
    }
    
    var totalAmount: Float = 0
    if let categories = BKCategory.fetchCategories() {
      for category in categories {
        
        let monthlyBudget = category.monthlyBudget
        if timeRangeType == .monthly {
          totalAmount += monthlyBudget
        } else {
          totalAmount += monthlyBudget * 12
        }
      }
    }
    
    overallAmountPieView.updateTotalAmount(totalAmount)
    overallAmountPieView.updatePrimaryAmount(overallAmount.amount, withAnimation: animationEnabled)
    overallAmountPieView.updateSecondaryAmount(totalAmount * completionPercentage, withAnimation: animationEnabled)
    
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
      self.overallAmountPieView.alpha = 1.0;
    }, completion: nil)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func filterButtonTapped() {
    
    let userFilterViewController = UserFilterViewController(nibName: "UserFilterViewController", bundle: nil)
    userFilterViewController.delegate = self
    userFilterViewController.currentUser = user
    let topSlideViewController = TopSlideViewController(presenting: userFilterViewController, from: self)
    present(topSlideViewController, animated: true, completion: nil)
  }
}

// MARK: - User Filter Delegate Methods
extension DataHeaderViewController: UserFilterDelegate {
  func shouldDismissUserFilter() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Top Slide Delegate Methods
extension DataHeaderViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension DataHeaderViewController: UIViewControllerTransitioningDelegate {

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

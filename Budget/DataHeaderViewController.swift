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
  
  var startDate: Date = Date().startAndEndOfMonth().startDate
  var endDate: Date = Date().startAndEndOfMonth().endDate
  
  /*var date: Date = Date() {
    didSet {
      if viewIsLoaded {
        if timeRangeType == .monthly {
          dateLabel.text = date.monthYearString()
        } else {
          dateLabel.text = date.yearString()
        }
      }
    }
  }*/
  
  var user: BKUser? /*{
    didSet {
      if viewIsLoaded {
        if let user = user {
          filterButton?.setTitle(user.name ?? "", for: .normal)
        } else {
          filterButton?.setTitle("Everyone", for: .normal)
        }
      }
    }
  }*/
  
  /*var timeRangeType: TimeRangeType = .monthly {
    didSet {
      if viewIsLoaded {
        if timeRangeType == .monthly {
          dateLabel.text = date.monthYearString()
        } else {
          dateLabel.text = date.yearString()
        }
      }
    }
  }*/
  
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var filterButton: BHButton!
  @IBOutlet weak var overallAmountPieView: AmountPieView!
  var overallAmount: BKAmount!
  var viewIsLoaded: Bool = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    dateLabel.textColor = UIColor.text
    filterButton.themeColor = UIColor.text
    filterButton.isCircular = true
    filterButton.isPrimaryAction = false
    
    if let user = user {
      filterButton.setTitle(user.name ?? "", for: .normal)
    } else {
      filterButton.setTitle("Everyone", for: .normal)
    }
    
    if Utilities.datesRepresentMonthlyRange(startDate, endDate) {
      dateLabel.text = startDate.monthYearString()
    } else if Utilities.datesRepresentAnnualRange(startDate, endDate) {
      dateLabel.text = startDate.yearString()
    } else {
      dateLabel.text = "\(startDate.monthYearString()) - \(endDate.monthYearString())"
    }
    
    BKAmount.getAmount(forUser: user, startDate: startDate, endDate: endDate) { (amount) in
      self.overallAmount = amount
      self.reloadOverallAmountDataView(withAnimation: false)
    }
    
    viewIsLoaded = true
  }
  
  func update(withStartDate startDate: Date, endDate: Date, user: BKUser?, animation: Bool) {
    
    self.user = user
    self.startDate = startDate
    self.endDate = endDate
    
    if !viewIsLoaded {
      return
    }
    
    if let user = user {
      filterButton.setTitle(user.name ?? "", for: .normal)
    } else {
      filterButton.setTitle("Everyone", for: .normal)
    }
    
    if Utilities.datesRepresentMonthlyRange(startDate, endDate) {
      dateLabel.text = startDate.monthYearString()
    } else if Utilities.datesRepresentAnnualRange(startDate, endDate) {
      dateLabel.text = startDate.yearString()
    } else {
      dateLabel.text = "\(startDate.monthYearString()) - \(endDate.monthYearString())"
    }
    
    BKAmount.getAmount(forUser: user, startDate: startDate, endDate: endDate) { (amount) in
      self.overallAmount = amount
      self.reloadOverallAmountDataView(withAnimation: animation)
    }
  }
  
  func reloadOverallAmountDataView(withAnimation animationEnabled: Bool) {
    
    let completionPercentage: Float
    
    if Utilities.datesRepresentMonthlyRange(startDate, endDate) && startDate.isMonthEqualTo(Date()) {
      completionPercentage = Date().completionPercentageOfMonth()
    } else if Utilities.datesRepresentAnnualRange(startDate, endDate) && startDate.isYearEqualTo(Date()) {
      completionPercentage = Date().completionPercentageOfYear()
    } else {
      completionPercentage = 0
    }
    
    var totalAmount: Float = 0
    if let categories = BKCategory.fetchCategories() {
      for category in categories {
        
        let monthlyBudget = category.monthlyBudget
        if Utilities.datesRepresentMonthlyRange(startDate, endDate) {
          totalAmount += monthlyBudget
        } else {
          totalAmount += monthlyBudget * 12
        }
      }
    }
    
    overallAmountPieView.updateTotalAmount(totalAmount)
    overallAmountPieView.updatePrimaryAmount(overallAmount.amount, withAnimation: animationEnabled)
    overallAmountPieView.updateSecondaryAmount(totalAmount * completionPercentage, withAnimation: animationEnabled)
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

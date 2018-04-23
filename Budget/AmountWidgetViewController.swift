//
//  AmountWidgetViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-03-16.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol AmountWidgetDelegate: class {
  func didSelect(category: BKCategory)
}

class AmountWidgetViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  weak var amountWidgetDelegate: AmountWidgetDelegate?
  
  @IBOutlet weak var amountPieView: AmountPieView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  var timeRangeType: TimeRangeType = .monthly
  var amount: BKAmount!
  var completionPercentage: Float = 0
  var shouldHideLabels: Bool = false
  
  private var category: BKCategory? {
    didSet {
      if let category = category {
        categoryLabel.text = category.name
      } else {
        categoryLabel.text = "Uncategorized"
      }
    }
  }
  
  init(withAmount amount: BKAmount, timeRangeType: TimeRangeType?, completionPercentage: Float?) {
    super.init(nibName: "AmountWidgetViewController", bundle: nil);
        
    self.amount = amount
    
    if let timeRangeType = timeRangeType {
      self.timeRangeType = timeRangeType
    }
    
    if let completionPercentage = completionPercentage {
      self.completionPercentage = completionPercentage
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  func refreshView(withAnimation animationEnabled: Bool) {
    
    var color: UIColor
    var monthlyBudget: Float?
    
    if let categoryID = amount.categoryID, let category = BKCategory.fetchCategory(withCloudID: categoryID) {
      color = category.color
      monthlyBudget = category.monthlyBudget
      self.category = category
    } else {
      color = UIColor.neutral
      monthlyBudget = nil
      self.category = nil
    }
    
    categoryLabel.isHidden = shouldHideLabels
    amountLabel.isHidden = shouldHideLabels
    
    let spentAmountString = amount.amount.simpleDollarAmount()
    let totalAmountString: String
    
    if let monthlyBudget = monthlyBudget {
      
      var totalAmount: Float
      if timeRangeType == .monthly {
        totalAmount = monthlyBudget
      } else {
        totalAmount = monthlyBudget * 12
      }
      
      amountPieView.updateTotalAmount(totalAmount)
      amountPieView.updatePrimaryAmount(amount.amount, withAnimation: animationEnabled)
      amountPieView.updateSecondaryAmount(totalAmount * completionPercentage, withAnimation: animationEnabled)
      totalAmountString = totalAmount.simpleDollarAmount()
      
      let attributedString = NSMutableAttributedString(string: "\(spentAmountString) of \(totalAmountString)")
      attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium), range: NSMakeRange(0, spentAmountString.count))
      attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium), range: NSMakeRange(spentAmountString.count + 4, totalAmountString.count))
      
      if amount.amount > totalAmount {
        attributedString.addAttribute(NSAttributedStringKey.foregroundColor, value: UIColor.negative, range: NSMakeRange(0, spentAmountString.count))
      }
      
      amountLabel.attributedText = attributedString
      
    } else {
      
      amountPieView.updateTotalAmount(amount.amount / completionPercentage)
      amountPieView.updatePrimaryAmount(amount.amount, withAnimation: animationEnabled)
      amountPieView.updateSecondaryAmount(amount.amount, withAnimation: animationEnabled)
      totalAmountString = ""
      
      let attributedString = NSMutableAttributedString(string: "\(spentAmountString)")
      attributedString.addAttribute(NSAttributedStringKey.font, value: UIFont.systemFont(ofSize: 15.0, weight: UIFont.Weight.medium), range: NSMakeRange(0, spentAmountString.count))
      
      amountLabel.attributedText = attributedString
    }
    
    categoryLabel.textColor = color
    amountPieView.updateThemeColor(color)
    amountLabel.textColor = color
    
    if amountLabel.alpha == 0 {
      UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
        self.amountLabel.alpha = 1
      }, completion: nil)
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func amountWidgetTapped() {
    
    if let category = category {
      amountWidgetDelegate?.didSelect(category: category)
    } else {
      let confirmAction = BHAlertAction(withTitle: "Got It", action: {
        self.dismiss(animated: true, completion: nil)
      })
      
      let alertViewController = BHAlertViewController(withTitle: "Sorry...", message: "There's no way to view uncategorized expenses grouped together at the moment.", actions: [confirmAction])
      let topSlideViewController = TopSlideViewController(presenting: alertViewController, from: self)
      present(topSlideViewController, animated: true, completion: nil)
    }
  }
}


// MARK: - Top Slide Delegate Methods
extension AmountWidgetViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension AmountWidgetViewController: UIViewControllerTransitioningDelegate {
  
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

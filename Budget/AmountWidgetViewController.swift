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

class AmountWidgetViewController: UIViewController {
  
  weak var amountWidgetDelegate: AmountWidgetDelegate?
  
  @IBOutlet weak var amountPieView: AmountPieView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  private var isPlaceholder: Bool = false {
    didSet {
      amountLabel.alpha = 0
    }
  }
  
  private var timeRangeType: TimeRangeType = .monthly
  var amount: BKAmount!
  private var completionPercentage: Float = 0
  
  private var category: BKCategory! {
    didSet {
      categoryLabel.text = category.name
    }
  }
  
  init(withAmount amount: BKAmount, timeRangeType: TimeRangeType?, completionPercentage: Float?, isPlaceholder: Bool? = false) {
    super.init(nibName: "AmountWidgetViewController", bundle: nil);
        
    self.amount = amount
    
    if let timeRangeType = timeRangeType {
      self.timeRangeType = timeRangeType
    }
    
    if let completionPercentage = completionPercentage {
      self.completionPercentage = completionPercentage
    }
    
    if let isPlaceholder = isPlaceholder {
      self.isPlaceholder = isPlaceholder
    }
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  func refreshView() {
    if let category = BKCategory.fetchCategory(withCloudID: amount.categoryID!) {
      self.category = category
      
      if isPlaceholder {
        amountPieView.totalAmount = 1
        amountPieView.primaryAmount = 0
        amountPieView.secondaryAmount = 0
        categoryLabel.textColor = category.color
        amountPieView.themeColor = category.color
        return
      }
      
      
      var totalAmount: Float
      
      if timeRangeType == .monthly {
        totalAmount = category.monthlyBudget
      } else {
        totalAmount = category.monthlyBudget * 12
      }
      
      amountPieView.totalAmount = totalAmount
      amountPieView.primaryAmount = amount.amount
      amountPieView.secondaryAmount = totalAmount * completionPercentage
      categoryLabel.textColor = category.color
      amountPieView.themeColor = category.color
      amountLabel.textColor = category.color
      
      let spentAmountString = amount.amount.simpleDollarAmount
      let totalAmountString = totalAmount.simpleDollarAmount
      
      let attributedString = NSMutableAttributedString(string: "\(spentAmountString) of \(totalAmountString)")
      attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightMedium), range: NSMakeRange(0, spentAmountString.characters.count))
      attributedString.addAttribute(NSFontAttributeName, value: UIFont.systemFont(ofSize: 15.0, weight: UIFontWeightMedium), range: NSMakeRange(spentAmountString.characters.count + 4, totalAmountString.characters.count))
      
      if amount.amount > totalAmount {
        attributedString.addAttribute(NSForegroundColorAttributeName, value: UIColor.overBudget, range: NSMakeRange(0, spentAmountString.characters.count))
      }
      
      amountLabel.attributedText = attributedString
      
      if amountLabel.alpha == 0 && !isPlaceholder {
        UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
          self.amountLabel.alpha = 1
        }, completion: nil)
      }
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func amountWidgetTapped() {
    if !isPlaceholder {
      amountWidgetDelegate?.didSelect(category: category)
    }
  }
}

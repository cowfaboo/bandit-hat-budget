//
//  AmountDataCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-11.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class AmountDataCell: UICollectionViewCell {

  @IBOutlet weak var amountView: AmountView!
  @IBOutlet weak var categoryLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  var isPlaceholder: Bool = false {
    didSet {
      amountLabel.alpha = 0
    }
  }
  
  var timeRangeType: TimeRangeType = .monthly {
    didSet {
      refreshView()
    }
  }
  
  var amount: BKAmount! {
    didSet {
      refreshView()
    }
  }
  
  var completionPercentage: Float = 0 {
    didSet {
      refreshView()
    }
  }
  
  private var category: BKCategory! {
    didSet {
      categoryLabel.text = category.name
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    print("awake from nib")
  }
  
  func refreshView() {
    print("refresh view")
    if let category = BKCategory.fetchCategory(withCloudID: amount.categoryID!) {
      self.category = category
      
      var totalAmount: Float
      
      if timeRangeType == .monthly {
        totalAmount = category.monthlyBudget
      } else {
        totalAmount = category.monthlyBudget * 12
      }
      amountView.totalAmount = totalAmount
      amountView.primaryAmount = amount.amount
      amountView.secondaryAmount = totalAmount * completionPercentage
      categoryLabel.textColor = category.color
      amountView.themeColor = category.color
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
}

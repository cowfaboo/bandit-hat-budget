//
//  ExpenseDataCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-12.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class ExpenseDataCell: UITableViewCell {
  
  @IBOutlet var nameLabel: UILabel!
  @IBOutlet var categoryLabel: UILabel!
  @IBOutlet var amountLabel: UILabel!
  @IBOutlet var dateLabel: UILabel!
  
  
  var expense: BKExpense! {
    didSet {
      
      nameLabel.text = expense.name
      nameLabel.textColor = UIColor.text
      amountLabel.text = expense.amount.dollarAmount()
      amountLabel.textColor = UIColor.text
      dateLabel.text = "\((expense.date as Date).dayOfMonth())"
      
      guard let categoryID = expense.category?.cloudID, let category = BKCategory.fetchCategory(withCloudID: categoryID) else {
        categoryLabel.text = "Uncategorized"
        categoryLabel.textColor = UIColor.text.withAlphaComponent(0.5)
        return
      }
      
      categoryLabel.text = category.name
      categoryLabel.textColor = category.color
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}

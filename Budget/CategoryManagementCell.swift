//
//  CategoryManagementCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-04-03.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class CategoryManagementCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var amountLabel: UILabel!
  
  var category: BKCategory! {
    didSet {
      
      nameLabel.text = category.name
      nameLabel.textColor = category.color
      amountLabel.text = category.monthlyBudget.simpleDollarAmount()
      amountLabel.textColor = UIColor.text
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
    
    // Configure the view for the selected state
  }
  
}

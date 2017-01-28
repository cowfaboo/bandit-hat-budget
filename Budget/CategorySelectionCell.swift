//
//  CategorySelectionCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-01-16.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class CategorySelectionCell: UICollectionViewCell {
  
  @IBOutlet weak var categoryLabel: UILabel!
  
  var category: BKCategory! {
    didSet {
      categoryLabel.textColor = category.color
      categoryLabel.text = category.name
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
  }
}

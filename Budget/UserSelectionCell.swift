//
//  UserSelectionCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-06.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserSelectionCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  
  var user: BKUser! {
    didSet {
      nameLabel.text = user.name
    }
  }
  
  var themeColor: UIColor? {
    didSet {
      nameLabel.textColor = themeColor
      //self.selectedBackgroundView?.backgroundColor = themeColor?.withAlphaComponent(0.04)
      self.tintColor = themeColor
    }
  }
  
  var userIsSelected = false {
    didSet {
      if userIsSelected {
        accessoryType = .checkmark
      } else {
        accessoryType = .none
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    //let backgroundView = UIView()
    //backgroundView.backgroundColor = themeColor?.withAlphaComponent(0.04)
    //self.selectedBackgroundView = backgroundView
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}

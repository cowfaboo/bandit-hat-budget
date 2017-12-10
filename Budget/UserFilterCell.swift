//
//  UserFilterCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-26.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserFilterCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  @IBOutlet weak var nameLabelLeadingConstraint: NSLayoutConstraint!
  
  var user: BKUser! {
    didSet {
      if let user = user {
        nameLabel.text = user.name
        nameLabel.font = UIFont.systemFont(ofSize: 18.0)
      } else {
        nameLabel.text = "Everyone"
        nameLabel.font = UIFont.systemFont(ofSize: 20.0, weight: UIFont.Weight.medium)
      }
    }
  }
  
  var themeColor: UIColor? {
    didSet {
      nameLabel.textColor = themeColor
      self.selectedBackgroundView?.backgroundColor = themeColor?.withAlphaComponent(0.04)
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
    let backgroundView = UIView()
    backgroundView.backgroundColor = themeColor?.withAlphaComponent(0.04)
    self.selectedBackgroundView = backgroundView
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}

//
//  UserManagementCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2018-01-02.
//  Copyright © 2018 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserManagementCell: UITableViewCell {
  
  @IBOutlet weak var nameLabel: UILabel!
  
  var user: BKUser! {
    didSet {
      
      if Settings.claimedUserID() == user.cloudID {
        nameLabel.textColor = .positive
        accessoryType = .checkmark
        tintColor = .positive
      } else {
        nameLabel.textColor = .text
        accessoryType = .none
        tintColor = .text
      }
      
      nameLabel.text = user.name
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

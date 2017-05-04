//
//  SettingsCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-03-27.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

class SettingsCell: UITableViewCell {
  
  @IBOutlet var titleLabel: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()
    
    accessoryType = .disclosureIndicator
    selectedBackgroundView = UIView()
    selectedBackgroundView?.backgroundColor = UIColor(white: 0.97, alpha: 1.0)
    titleLabel.textColor = UIColor.text
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
  
}

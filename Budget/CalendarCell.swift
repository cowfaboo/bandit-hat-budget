//
//  CalendarCell.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-19.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

class CalendarCell: UICollectionViewCell {
  
  @IBOutlet weak var dateLabel: UILabel!
  @IBOutlet weak var selectionView: UIView!
  var themeColor: UIColor?
  
  func initialize(withDay day: Int?, shouldDimDate: Bool = false, shouldHighlightDate: Bool = false, shouldSelectDate: Bool = false) {
    
    selectionView.backgroundColor = UIColor.clear
    selectionView.alpha = 1.0
    dateLabel.textColor = UIColor.text
    dateLabel.font = UIFont.systemFont(ofSize: 17.0, weight: UIFont.Weight.medium)
    dateLabel.alpha = 1.0
    
    if let day = day {
      dateLabel.text = "\(day)"
    } else {
      dateLabel.text = ""
    }
    
    if shouldSelectDate {
      dateLabel.textColor = UIColor.white
      if let themeColor = themeColor {
        selectionView.backgroundColor = themeColor
      } else {
        selectionView.backgroundColor = UIColor.text.withAlphaComponent(0.5)
      }
    } else if shouldHighlightDate {
      dateLabel.textColor = UIColor.negative
      dateLabel.font = UIFont.systemFont(ofSize: 19.0, weight: UIFont.Weight.medium)
    }
    
    if shouldDimDate {
      selectionView.alpha = 0.15
      if !shouldSelectDate {
        dateLabel.alpha = 0.25
      }
    }
  }
  
  override func awakeFromNib() {
    super.awakeFromNib()
    dateLabel.textColor = UIColor.text
  }
  
  override func layoutSubviews() {
    super.layoutSubviews()
    selectionView.setNeedsLayout()
    selectionView.layoutIfNeeded()
    selectionView.layer.cornerRadius = selectionView.frame.size.width / 2.0
  }
  
}

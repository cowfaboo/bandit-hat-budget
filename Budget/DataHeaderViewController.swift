//
//  DataHeaderViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-18.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class DataHeaderViewController: UIViewController {
  
  var date: Date = Date()
  var timeRangeType: TimeRangeType = .monthly
  
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var filterButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if timeRangeType == .monthly {
      dateLabel.text = date.monthYearString()
    } else {
      dateLabel.text = date.yearString()
    }
    
    dateLabel.textColor = UIColor.text
    filterButton.setTitleColor(UIColor.text.withAlphaComponent(0.5), for: .normal)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
}

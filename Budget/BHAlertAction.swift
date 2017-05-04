//
//  BHAlertAction.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-04-22.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import Foundation

class BHAlertAction {
  
  var action: (() -> ())
  var title: String
  var color: UIColor
  
  init(withTitle title: String, color: UIColor = UIColor.text, action: @escaping () -> ()) {
   
    self.title = title
    self.action = action
    self.color = color
  }
}

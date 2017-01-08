//
//  AmountView.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-11.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class AmountView: UIView {
  
  var totalAmount: Float = 0 {
    didSet {
      (layer as! AmountLayer).totalAmount = totalAmount
    }
  }
  
  var primaryAmount: Float = 0 {
    didSet {
      (layer as! AmountLayer).primaryAmount = primaryAmount
    }
  }
  
  var secondaryAmount: Float = 0 {
    didSet {
      (layer as! AmountLayer).secondaryAmount = secondaryAmount
    }
  }
  
  var themeColor: UIColor = UIColor.text {
    didSet {
      (layer as! AmountLayer).themeColor = themeColor
    }
  }
  
  override class var layerClass: AnyClass {
    return AmountLayer.self
  }
}

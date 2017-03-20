//
//  AmountPieView.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-11.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class AmountPieView: UIView {
  
  var totalAmount: Float = 0 {
    didSet {
      (layer as! AmountPieLayer).totalAmount = totalAmount
    }
  }
  
  var primaryAmount: Float = 0 {
    didSet {
      (layer as! AmountPieLayer).primaryAmount = primaryAmount
    }
  }
  
  var secondaryAmount: Float = 0 {
    didSet {
      (layer as! AmountPieLayer).secondaryAmount = secondaryAmount
    }
  }
  
  var themeColor: UIColor = UIColor.text {
    didSet {
      (layer as! AmountPieLayer).themeColor = themeColor
    }
  }
  
  override class var layerClass: AnyClass {
    return AmountPieLayer.self
  }
}

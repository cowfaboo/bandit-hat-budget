//
//  AmountPieView.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-11.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class AmountPieView: UIView {
  
  func updatePrimaryAmount(_ primaryAmount: Float, withAnimation animationEnabled: Bool = false) {
    (layer as! AmountPieLayer).animationEnabled = animationEnabled
    (layer as! AmountPieLayer).primaryAmount = primaryAmount
  }
  
  func updateSecondaryAmount(_ secondaryAmount: Float, withAnimation animationEnabled: Bool = false) {
    (layer as! AmountPieLayer).animationEnabled = animationEnabled
    (layer as! AmountPieLayer).secondaryAmount = secondaryAmount
  }
  
  func updateTotalAmount(_ totalAmount: Float) {
    (layer as! AmountPieLayer).totalAmount = totalAmount
  }
  
  func updateThemeColor(_ themeColor: UIColor) {
    (layer as! AmountPieLayer).themeColor = themeColor
  }
  
  override class var layerClass: AnyClass {
    return AmountPieLayer.self
  }
}

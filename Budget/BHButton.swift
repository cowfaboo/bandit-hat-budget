//
//  BHButton.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-11.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class BHButton: UIButton {
  
  var cornerRadius: CGFloat = 8.0
  
  override func awakeFromNib() {

    if frame.height > 40 {
      cornerRadius = 8.0
    } else {
      cornerRadius = 4.0
    }
    
    layer.cornerRadius = cornerRadius
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
    layer.shadowOpacity = 0.1
    layer.shadowRadius = 2.0
    layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    setTitleColor(themeColor, for: .normal)
    setTitleColor(themeColor.withAlphaComponent(0.5), for: .disabled)
    setTitleShadowColor(UIColor.clear, for: .normal)
    tintColor = themeColor
    
    backgroundColor = UIColor.white
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    if isCircular {
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2.0).cgPath
    } else {
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
  }
  
  override var isEnabled: Bool {
    didSet {
      if isEnabled {
        layer.shadowRadius = 2.0
        layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
      } else {
        layer.shadowOffset = CGSize()
        layer.shadowRadius = 1.0
      }
    }
  }
  
  var themeColor: UIColor = UIColor.text {
    didSet {
      setTitleColor(themeColor, for: .normal)
      setTitleColor(themeColor.withAlphaComponent(0.5), for: .disabled)
      tintColor = themeColor
    }
  }
  
  var isCircular: Bool = false {
    didSet {
      layer.cornerRadius = bounds.width / 2.0
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width / 2.0).cgPath
    }
  }
  
}

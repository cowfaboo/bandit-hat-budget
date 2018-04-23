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
  
  init() {
    super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
    
    cornerRadius = 8.0
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
    layer.shadowOpacity = 0.1
    layer.shadowRadius = 2.0
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    if isCircular {
      layer.cornerRadius = bounds.height / 2.0
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2.0).cgPath
    } else {
      layer.cornerRadius = cornerRadius
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    setTitleColor(themeColor, for: .normal)
    setTitleColor(themeColor.withAlphaComponent(0.5), for: .disabled)
    setTitleShadowColor(UIColor.clear, for: .normal)
    tintColor = themeColor
    backgroundColor = UIColor.white
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override func awakeFromNib() {

    cornerRadius = 8.0
    
    layer.shadowColor = UIColor.black.cgColor
    layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
    layer.shadowOpacity = 0.1
    layer.shadowRadius = 2.0
    layer.shouldRasterize = true
    layer.rasterizationScale = UIScreen.main.scale
    
    if isCircular {
      layer.cornerRadius = bounds.height / 2.0
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2.0).cgPath
    } else {
      layer.cornerRadius = cornerRadius
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
    }
    
    setTitleColor(themeColor, for: .normal)
    setTitleColor(themeColor.withAlphaComponent(0.5), for: .disabled)
    setTitleShadowColor(UIColor.clear, for: .normal)
    tintColor = themeColor
    
    backgroundColor = UIColor.white
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    
    if isCircular {
      layer.cornerRadius = bounds.height / 2.0
      layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2.0).cgPath
    } else {
      layer.cornerRadius = cornerRadius
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
  
  var isCircular: Bool = true {
    didSet {
      if isCircular {
        layer.cornerRadius = bounds.height / 2.0
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.height / 2.0).cgPath
      } else {
        layer.cornerRadius = cornerRadius
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius).cgPath
      }
    }
  }
  
  var isPrimaryAction: Bool = true {
    didSet {
      if isPrimaryAction {
        layer.shadowOffset = CGSize(width: 0.5, height: 1.0)
        layer.shadowRadius = 2.0
      } else {
        layer.shadowOffset = CGSize(width: 0.0, height: 0.0)
        layer.shadowOpacity = 0.15
        layer.shadowRadius = 1.0
      }
    }
  }
  
}

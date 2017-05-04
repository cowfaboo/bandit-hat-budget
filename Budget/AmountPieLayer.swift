//
//  AmountPieLayer.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-27.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

class AmountPieLayer: CAShapeLayer {
  
  var themeColor: UIColor = UIColor.text {
    didSet {
      setNeedsLayout()
    }
  }
  
  var totalAmount: Float = 0
  
  @NSManaged var primaryAmount: Float
  
  @NSManaged var secondaryAmount: Float
  
  override func layoutSublayers() {
    if primaryAmount == 0 && secondaryAmount == 0 {
      path = UIBezierPath(ovalIn: CGRect(x: 6, y: 6, width: bounds.size.width - 12, height: bounds.size.height - 12)).cgPath
      fillColor = themeColor.withAlphaComponent(0.1).cgColor
    }
  }
  
  override func display() {
    
    // total amount is what the entire circle is worth. primary amount is how much of that 
    // is filled in. secondary amount is how much *should* be filled in given the current date.
    // if secondary amount > primary amount, secondary angle is green, starts at primary and ends at secondary.
    // if primary amount > secondary amount, secondary angle is red, starts at secondary and ends at primary.
    fillColor = UIColor.clear.cgColor
    
    let cgTotalAmount = CGFloat(totalAmount)
    var cgPrimaryAmount = CGFloat((presentation()?.primaryAmount) ?? 0)
    let cgSecondaryAmount = CGFloat((presentation()?.secondaryAmount) ?? 0)
    
    let cgExcessAmount = max(cgPrimaryAmount - cgTotalAmount, 0)
    if cgExcessAmount > 0 {
      cgPrimaryAmount = cgTotalAmount
    }
    
    UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
    let context = UIGraphicsGetCurrentContext()
    
    var radius: CGFloat
    var viewCenter: CGPoint
    let zeroAngle: CGFloat = -CGFloat(Double.pi / 2.0)
    var startAngle: CGFloat
    var endAngle: CGFloat
    
    
    // fill in secondary angle if cgSecondaryAmount isn't zero
    if (cgSecondaryAmount > 0) {
      
      if (cgSecondaryAmount > cgPrimaryAmount) {
        context?.setFillColor(UIColor.positive.cgColor)
        radius = min(frame.size.width, frame.size.height) * 0.5
        viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        startAngle = zeroAngle + CGFloat(Double.pi * 2) * ((cgPrimaryAmount + cgExcessAmount) / cgTotalAmount)
        endAngle = zeroAngle + CGFloat(Double.pi * 2) * (cgSecondaryAmount / cgTotalAmount)
        
        context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
        context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context?.fillPath()
        
      } else {
        context?.setFillColor(UIColor.negative.cgColor)
        radius = min(frame.size.width, frame.size.height) * 0.5
        viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
        startAngle = zeroAngle + CGFloat(Double.pi * 2) * (cgSecondaryAmount / cgTotalAmount)
        endAngle = zeroAngle + CGFloat(Double.pi * 2) * ((cgPrimaryAmount + cgExcessAmount) / cgTotalAmount)
        
        context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
        context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
        context?.fillPath()
      }
    }
    
    
    // fill in light background color
    context?.setFillColor(UIColor.white.cgColor)
    radius = min(frame.size.width - 4, frame.size.height - 4) * 0.5
    viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    startAngle = zeroAngle
    endAngle = zeroAngle + CGFloat(Double.pi * 2)
    
    context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
    context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    context?.fillPath()
    
    context?.setFillColor(themeColor.withAlphaComponent(0.1).cgColor)
    
    radius = min(frame.size.width - 12, frame.size.height - 12) * 0.5
    viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    startAngle = zeroAngle
    endAngle = zeroAngle + CGFloat(Double.pi * 2)
    
    context?.move(to: CGPoint(x: viewCenter.x, y: 4))
    context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    context?.fillPath()
    
    
    // fill in angle
    context?.setFillColor(themeColor.withAlphaComponent(1.0).cgColor)
    
    radius = min(frame.size.width - 12, frame.size.height - 12) * 0.5
    viewCenter = CGPoint(x: bounds.size.width * 0.5, y: bounds.size.height * 0.5)
    startAngle = zeroAngle
    endAngle = zeroAngle + CGFloat(Double.pi * 2) * (cgPrimaryAmount / cgTotalAmount)
    
    context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
    context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: radius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
    context?.fillPath()
    
    
    // fill in excess angle
    if cgExcessAmount > 0 {
      
      let excessRadius = min(frame.size.width - 12, frame.size.height - 12) * 0.5
      
      context?.setFillColor(UIColor.negative.cgColor)
      context?.setStrokeColor(UIColor.white.cgColor)
      context?.setLineWidth(2.0)
      let endAngle = startAngle + CGFloat(Double.pi * 2) * (cgExcessAmount / cgTotalAmount)
      context?.move(to: CGPoint(x: viewCenter.x, y: viewCenter.y))
      context?.addArc(center: CGPoint(x: viewCenter.x, y: viewCenter.y), radius: excessRadius, startAngle: startAngle, endAngle: endAngle, clockwise: false)
      context?.closePath()
      context?.drawPath(using: .fillStroke)
    }
    
    contents = UIGraphicsGetImageFromCurrentImageContext()?.cgImage
    UIGraphicsEndImageContext()
  }
  
  override func action(forKey event: String) -> CAAction? {
   
    if event == #keyPath(primaryAmount) {
      
      let animation = CABasicAnimation(keyPath: event)
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
      animation.duration = 0.6
      animation.fromValue = primaryAmount
      return animation
      
    } else if event == #keyPath(secondaryAmount) {
      
      let animation = CABasicAnimation(keyPath: event)
      animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionDefault)
      animation.duration = 0.6
      animation.fromValue = secondaryAmount
      return animation
    }
    
    return super.action(forKey: event)
  }
  
  override class func needsDisplay(forKey key: String) -> Bool {
    
    if key == #keyPath(primaryAmount) || key == #keyPath(secondaryAmount) {
      return true
    }
    
    return super.needsDisplay(forKey: key)
  }
}

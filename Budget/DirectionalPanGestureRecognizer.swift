//
//  DirectionalPanGestureRecognizer.swift
//  Volley_ListPrototype
//
//  Created by Daniel Gauthier on 2015-04-21.
//  Copyright (c) 2015 Volley. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

enum GestureDirection {
  case Vertical
  case Horizontal
  case StrictVertical
  case StrictHorizontal
}

class DirectionalPanGestureRecognizer: UIPanGestureRecognizer {
  var drag: Bool = false
  var moveX: Int = 0
  var moveY: Int = 0
  var gestureDirection: GestureDirection = .Vertical
  
  
  override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
    super.touchesMoved(touches, with: event)
    
    if state == UIGestureRecognizerState.failed {
      return
    }
    
    let touch: UITouch = touches.first! as UITouch
    let nowPoint: CGPoint = touch.location(in: view)
    let prevPoint: CGPoint = touch.previousLocation(in: view)
    moveX += Int(prevPoint.x - nowPoint.x)
    moveY += Int(prevPoint.y - nowPoint.y)
    
    if !drag {
      if abs(moveX) > abs(moveY) {
        
        if gestureDirection == .StrictHorizontal {
          
          if moveY == 0 || CGFloat(abs(moveX)) / CGFloat(abs(moveY)) > 1.8 {
            drag = true
          } else {
            state = .failed
          }
        } else if gestureDirection == .Vertical {
          state = .failed
        } else {
          drag = true
        }
      } else if abs(moveY) > abs(moveX) {
                
        if gestureDirection == .Horizontal || gestureDirection == .StrictHorizontal {
          state = .failed
        } else {
          drag = true
        }
      }
    }
  }
  
  override func reset() {
    super.reset()
    drag = false
    moveX = 0
    moveY = 0
  }
}

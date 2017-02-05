//
//  BottomSlideAnimator.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-01-29.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

class BottomSlideAnimator: UIPercentDrivenInteractiveTransition {

  var presenting = true
  var interactive = false
  var initialCenter = CGPoint()
  /*var initialFrame = CGRect() {
    didSet {
      initialCenter = CGPoint(x: initialFrame.origin.x + initialFrame.size.width / 2, y: initialFrame.origin.y + initialFrame.size.height / 2)
    }
  }*/
  
  var distanceToTravel: CGFloat = 1
  var velocity: CGFloat = 0
  
  weak var transitionContext: UIViewControllerContextTransitioning?
  
  override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    
    self.transitionContext = transitionContext
    
    let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! BottomSlideViewController
    initialCenter = CGPoint(x: Utilities.screenWidth / 2.0, y: Utilities.screenHeight + (presentedViewController.containerView.frame.height / 2.0))
    
    self.update(0)
  }
  
  override func update(_ percentComplete: CGFloat) {
    
    if transitionContext == nil {
      return
    }
    
    transitionContext!.updateInteractiveTransition(percentComplete)
    
    let presentedViewController = transitionContext!.viewController(forKey: .from) as! BottomSlideViewController
    
    let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: 115.0 + (presentedViewController.containerView.frame.height / 2.0))
    let centerDifferenceX = finalCenter.x - initialCenter.x
    let centerDifferenceY = finalCenter.y - initialCenter.y
    
    presentedViewController.containerView.center = CGPoint(x: finalCenter.x - (centerDifferenceX * percentComplete), y: finalCenter.y - (centerDifferenceY * percentComplete))
    
    presentedViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.65 - (0.65 * percentComplete))
    
  }
  
  override func cancel() {
    
    if transitionContext == nil {
      return
    }
    
    let presentedViewController = transitionContext!.viewController(forKey: .from) as! BottomSlideViewController
    
    var springVelocity: CGFloat
    if distanceToTravel == 0 {
      springVelocity = 0
    } else {
      springVelocity = velocity / distanceToTravel
    }
    
    let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: 115.0 + (presentedViewController.containerView.frame.height / 2.0))
    UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: [], animations: { () -> Void in
      
      presentedViewController.containerView.center = finalCenter
      presentedViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
    }, completion: { (finished: Bool) -> Void in
      //containerViewController?.view.isHidden = true
      self.transitionContext!.cancelInteractiveTransition()
      self.transitionContext!.completeTransition(false)
    })
  }
  
  override func finish() {
    
    if transitionContext == nil {
      return
    }
    
    let presentedViewController = transitionContext!.viewController(forKey: .from) as! BottomSlideViewController
    
    var springVelocity: CGFloat
    if distanceToTravel == 0 {
      springVelocity = 0
    } else {
      springVelocity = velocity / distanceToTravel
    }
    
    UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      
      presentedViewController.containerView.center = self.initialCenter
      presentedViewController.view.backgroundColor = UIColor.clear
    }, completion: { (finished: Bool) -> Void in
      self.transitionContext!.cancelInteractiveTransition()
      self.transitionContext!.completeTransition(true)
    })
  }
  
}

extension BottomSlideAnimator: UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    self.transitionContext = transitionContext
    let containerView = transitionContext.containerView
    
    if presenting {
      
      let bottomSlideViewController = transitionContext.viewController(forKey: .to) as! BottomSlideViewController
      
      bottomSlideViewController.view.frame = CGRect(x: 0, y: 0, width: Utilities.screenWidth, height: Utilities.screenHeight)
      containerView.addSubview(bottomSlideViewController.view)
      bottomSlideViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
      
      bottomSlideViewController.containerViewTopConstraint.constant = Utilities.screenHeight
      bottomSlideViewController.view.layoutIfNeeded()
      
      bottomSlideViewController.containerViewTopConstraint.constant = 115.0
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext) - 0.1, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { () -> Void in
        bottomSlideViewController.view.layoutIfNeeded()
      }, completion: nil)
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
        
        bottomSlideViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        
      }, completion: { (finished: Bool) -> Void in
        transitionContext.completeTransition(true)
      })
    } else {
      
      let bottomSlideViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! BottomSlideViewController
      
      bottomSlideViewController.containerViewTopConstraint.constant = Utilities.screenHeight
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { () -> Void in
        bottomSlideViewController.view.layoutIfNeeded()
      }, completion: nil)
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
        
        bottomSlideViewController.view.backgroundColor = UIColor.clear
        
      }, completion: { (finished: Bool) -> Void in
        transitionContext.completeTransition(true)
      })
    }
  }
}

//
//  TopSlideAnimator.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-20.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

class TopSlideAnimator: UIPercentDrivenInteractiveTransition {

  var presenting = true
  var interactive = false
  var initialCenter = CGPoint()
  
  var distanceToTravel: CGFloat = 1
  var velocity: CGFloat = 0
  
  weak var transitionContext: UIViewControllerContextTransitioning?
  
  override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    
    self.transitionContext = transitionContext
    
    let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! TopSlideViewController
    initialCenter = CGPoint(x: Utilities.screenWidth / 2.0, y: -presentedViewController.containerView.frame.height / 2.0)
    
    self.update(0)
  }
  
  override func update(_ percentComplete: CGFloat) {
    
    if transitionContext == nil {
      return
    }
    
    transitionContext?.updateInteractiveTransition(percentComplete)
    
    let presentedViewController = transitionContext!.viewController(forKey: .from) as! TopSlideViewController
    
    let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: 96.0 + (presentedViewController.containerView.frame.height / 2.0))
    let centerDifferenceX = finalCenter.x - initialCenter.x
    let centerDifferenceY = finalCenter.y - initialCenter.y
    
    presentedViewController.containerView.center = CGPoint(x: finalCenter.x - (centerDifferenceX * percentComplete), y: finalCenter.y - (centerDifferenceY * percentComplete))
    
    presentedViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.65 - (0.65 * percentComplete))
    
  }
  
  override func cancel() {
    
    if transitionContext == nil {
      return
    }
    
    let presentedViewController = transitionContext!.viewController(forKey: .from) as! TopSlideViewController
    
    var springVelocity: CGFloat
    if distanceToTravel == 0 {
      springVelocity = 0
    } else {
      springVelocity = velocity / distanceToTravel
    }
    
    let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: 96.0 + (presentedViewController.containerView.frame.height / 2.0))
    UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: [], animations: { () -> Void in
      
      presentedViewController.containerView.center = finalCenter
      presentedViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
    }, completion: { (finished: Bool) -> Void in
      self.transitionContext?.cancelInteractiveTransition()
      self.transitionContext?.completeTransition(false)
    })
  }
  
  override func finish() {
    
    if transitionContext == nil {
      return
    }
    
    let presentedViewController = transitionContext!.viewController(forKey: .from) as! TopSlideViewController
    
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
      self.transitionContext?.cancelInteractiveTransition()
      self.transitionContext?.completeTransition(true)
    })
  }
}

extension TopSlideAnimator: UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    self.transitionContext = transitionContext
    let containerView = transitionContext.containerView
    
    if presenting {
      
      let topSlideViewController = transitionContext.viewController(forKey: .to) as! TopSlideViewController
      
      topSlideViewController.view.frame = CGRect(x: 0, y: 0, width: Utilities.screenWidth, height: Utilities.screenHeight)
      containerView.addSubview(topSlideViewController.view)
      topSlideViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.0)
      
      topSlideViewController.containerViewTopConstraint.constant = -topSlideViewController.containerView.frame.size.height
      topSlideViewController.view.layoutIfNeeded()
      
      topSlideViewController.containerViewTopConstraint.constant = 96.0
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext) - 0.1, delay: 0.0, usingSpringWithDamping: 0.85, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { () -> Void in
        topSlideViewController.view.layoutIfNeeded()
      }, completion: nil)
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
        
        topSlideViewController.view.backgroundColor = UIColor.black.withAlphaComponent(0.65)
        
      }, completion: { (finished: Bool) -> Void in
        transitionContext.completeTransition(true)
      })
    } else {
      
      let topSlideViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) as! TopSlideViewController
      
      topSlideViewController.containerViewTopConstraint.constant = -topSlideViewController.containerView.frame.size.height
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { () -> Void in
        topSlideViewController.view.layoutIfNeeded()
      }, completion: nil)
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
        
        topSlideViewController.view.backgroundColor = UIColor.clear
        
      }, completion: { (finished: Bool) -> Void in
        transitionContext.completeTransition(true)
      })
    }
  }
}


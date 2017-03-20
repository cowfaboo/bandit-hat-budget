//
//  TopLayerAnimator.swift
//  Volley-iOS
//
//  Created by Daniel Gauthier on 2015-06-05.
//  Copyright (c) 2015 Volley. All rights reserved.
//

import UIKit

class TopLayerAnimator: UIPercentDrivenInteractiveTransition, PresentationAnimator {
  
  // MARK: Properties
  var presenting = true
  var interactive = false
  var initialCenter = CGPoint()
  
  var distanceToTravel: CGFloat = 1
  var velocity: CGFloat = 0
  
  weak var transitionContext: UIViewControllerContextTransitioning?
  
  var darkView: UIView!
  
  override func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
    
    self.transitionContext = transitionContext
    
    let containerViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
    containerViewController?.view.isHidden = false

    self.update(0)
  }
  
  override func update(_ percentComplete: CGFloat) {
    
    if transitionContext == nil {
      return
    }
    
    transitionContext?.updateInteractiveTransition(percentComplete)
    
    let containerViewController = transitionContext!.viewController(forKey: .to)
    let presentedViewController = transitionContext!.viewController(forKey: .from)
    
    let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight / 2)
    let centerDifferenceX = finalCenter.x - initialCenter.x
    let centerDifferenceY = finalCenter.y - initialCenter.y
    
    presentedViewController?.view.center = CGPoint(x: finalCenter.x - (centerDifferenceX * percentComplete), y: finalCenter.y - (centerDifferenceY * percentComplete))
    
    darkView.alpha = 1.0 - percentComplete
    containerViewController?.view.transform = CGAffineTransform(scaleX: 0.95 + 0.05 * percentComplete, y: 0.95 + 0.05 * percentComplete)
    
  }
  
  override func cancel() {
    
    if transitionContext == nil {
      return
    }
    
    let containerViewController = transitionContext!.viewController(forKey: .to)
    let presentedViewController = transitionContext!.viewController(forKey: .from)
    
    var springVelocity: CGFloat
    if distanceToTravel == 0 {
      springVelocity = 0
    } else {
      springVelocity = velocity / distanceToTravel
    }
    
    let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight / 2)
    UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: [], animations: { () -> Void in

      presentedViewController?.view.center = finalCenter
      self.darkView.alpha = 1.0
      containerViewController?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
      }, completion: { (finished: Bool) -> Void in
        containerViewController?.view.isHidden = true
        self.transitionContext?.cancelInteractiveTransition()
        self.transitionContext?.completeTransition(false)
    })
  }
  
  override func finish() {
    
    if transitionContext == nil {
      return
    }
    
    let containerViewController = transitionContext!.viewController(forKey: .to)
    let presentedViewController = transitionContext!.viewController(forKey: .from)
    
    var springVelocity: CGFloat
    if distanceToTravel == 0 {
      springVelocity = 0
    } else {
      springVelocity = velocity / distanceToTravel
    }
    
    UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      
      presentedViewController?.view.center = self.initialCenter
      self.darkView.alpha = 0.0
      containerViewController?.view.transform = CGAffineTransform.identity
      }, completion: { (finished: Bool) -> Void in
        self.darkView.removeFromSuperview()
        self.transitionContext?.cancelInteractiveTransition()
        self.transitionContext?.completeTransition(true)
    })
  }
}

extension TopLayerAnimator: UIViewControllerAnimatedTransitioning {
  
  func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
    return 0.5
  }
  
  func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
    
    if interactive {
      return
    }
    
    self.transitionContext = transitionContext
    let containerView = transitionContext.containerView
    
    if presenting {
      
      let containerViewController = transitionContext.viewController(forKey: .from)
      let presentedViewController = transitionContext.viewController(forKey: .to)
      
      presentedViewController?.view.frame = CGRect(x: initialCenter.x - (Utilities.screenWidth / 2), y: initialCenter.y - (Utilities.screenHeight / 2), width: Utilities.screenWidth, height: Utilities.screenHeight)
      containerView.addSubview(presentedViewController!.view)
      presentedViewController?.view.alpha = 1.0
      
      darkView = UIView(frame: CGRect(x: -50, y: -50, width: Utilities.screenWidth + 100, height: Utilities.screenHeight + 100))
      darkView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
      darkView.alpha = 0.0
      containerViewController?.view.addSubview(darkView)
      
      let finalCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight / 2)
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
        
        presentedViewController?.view.center = finalCenter
        containerViewController?.view.transform = CGAffineTransform(scaleX: 0.95, y: 0.95)
        
        }, completion: { (finished: Bool) -> Void in
          containerView.layoutIfNeeded()
          containerViewController?.view.isHidden = true
          transitionContext.completeTransition(true)
      })
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: { () -> Void in
        self.darkView.alpha = 1.0
      })
      
    } else {
      
      let containerViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to)
      let presentedViewController = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
      
      containerViewController?.view.isHidden = false
      
      UIView.animate(withDuration: transitionDuration(using: transitionContext), delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
        
        presentedViewController?.view.center = self.initialCenter
        containerViewController?.view.transform = CGAffineTransform.identity
        
        self.darkView.alpha = 0.0
        
        }, completion: { (finished: Bool) -> Void in
          
          self.darkView.removeFromSuperview()
          transitionContext.completeTransition(true)
      })
    }
  }
}

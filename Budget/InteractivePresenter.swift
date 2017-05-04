//
//  InteractivePresenter.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-05.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol InteractivePresenter: class {
  
  var presentationAnimator: PresentationAnimator { get }
  
  func interactiveDismissalBegan()
  func interactiveDismissalChanged(withProgress progress: CGFloat)
  func interactiveDismissalFinished(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat)
  func interactiveDismissalCanceled(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat)
  func interactivePresentationDismissed()
}

extension InteractivePresenter where Self: UIViewController {
  func interactiveDismissalBegan() {
    presentationAnimator.interactive = true
    dismiss(animated: true)
  }
  
  func interactiveDismissalChanged(withProgress progress: CGFloat) {
    if let interactiveTransition = presentationAnimator as? UIPercentDrivenInteractiveTransition {
      interactiveTransition.update(progress)
    }
  }
  
  func interactiveDismissalCanceled(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat) {
    presentationAnimator.distanceToTravel = distanceToTravel
    presentationAnimator.velocity = velocity
    if let interactiveTransition = presentationAnimator as? UIPercentDrivenInteractiveTransition {
      interactiveTransition.cancel()
    }
    presentationAnimator.interactive = false
  }
  
  func interactiveDismissalFinished(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat) {
    presentationAnimator.distanceToTravel = distanceToTravel
    presentationAnimator.velocity = velocity
    if let interactiveTransition = presentationAnimator as? UIPercentDrivenInteractiveTransition {
      interactiveTransition.finish()
    }
    presentationAnimator.interactive = false
    interactivePresentationDismissed()
  }
  
  func interactivePresentationDismissed() {
    
  }
}

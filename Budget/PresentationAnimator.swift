//
//  PresentationAnimator.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-03-11.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import Foundation

protocol PresentationAnimator: class, UIViewControllerAnimatedTransitioning, UIViewControllerInteractiveTransitioning {
  var presenting: Bool { get set }
  var interactive: Bool { get set }
  var initialCenter: CGPoint { get set }
  var distanceToTravel: CGFloat { get set }
  var velocity: CGFloat { get set }
}

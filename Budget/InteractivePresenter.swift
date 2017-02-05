//
//  InteractivePresenter.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-05.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol InteractivePresenter: class {
  func interactiveDismissalBegan()
  func interactiveDismissalChanged(withProgress progress: CGFloat)
  func interactiveDismissalFinished(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat)
  func interactiveDismissalCanceled(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat)
}

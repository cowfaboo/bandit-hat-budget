//
//  DataHeaderViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-18.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class DataHeaderViewController: UIViewController {
  
  var topSlideAnimator = TopSlideAnimator()
  
  var date: Date = Date()
  var user: BKUser? {
    didSet {
      if let user = user {
        filterButton?.setTitle(user.name ?? "", for: .normal)
      } else {
        filterButton?.setTitle("Everyone", for: .normal)
      }
    }
  }
  var timeRangeType: TimeRangeType = .monthly
  
  @IBOutlet private weak var dateLabel: UILabel!
  @IBOutlet private weak var filterButton: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if timeRangeType == .monthly {
      dateLabel.text = date.monthYearString()
    } else {
      dateLabel.text = date.yearString()
    }
    
    dateLabel.textColor = UIColor.text
    filterButton.setTitleColor(UIColor.text.withAlphaComponent(0.5), for: .normal)
    
    if let user = user {
      filterButton.setTitle(user.name ?? "", for: .normal)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func filterButtonTapped() {
    
    let userFilterViewController = UserFilterViewController(nibName: "UserFilterViewController", bundle: nil)
    userFilterViewController.delegate = self
    userFilterViewController.currentUser = user
    let topSlideViewController = TopSlideViewController(presenting: userFilterViewController, from: self)
    present(topSlideViewController, animated: true, completion: nil)
  }
}

// MARK: - User Filter Delegate Methods
extension DataHeaderViewController: UserFilterDelegate {
  func shouldDismissUserFilter() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Top Slide Delegate Methods
extension DataHeaderViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Interactive Presenter Methods
extension DataHeaderViewController: InteractivePresenter {
  
  func interactiveDismissalBegan() {
    topSlideAnimator.interactive = true
    dismiss(animated: true)
  }
  
  func interactiveDismissalChanged(withProgress progress: CGFloat) {
    topSlideAnimator.update(progress)
  }
  
  func interactiveDismissalCanceled(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat) {
    topSlideAnimator.distanceToTravel = distanceToTravel
    topSlideAnimator.velocity = velocity
    topSlideAnimator.cancel()
    topSlideAnimator.interactive = false
  }
  
  func interactiveDismissalFinished(withDistanceToTravel distanceToTravel: CGFloat, velocity: CGFloat) {
    topSlideAnimator.distanceToTravel = distanceToTravel
    topSlideAnimator.velocity = velocity
    topSlideAnimator.finish()
    topSlideAnimator.interactive = false
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension DataHeaderViewController: UIViewControllerTransitioningDelegate {
  
  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    topSlideAnimator.presenting = true
    return topSlideAnimator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    topSlideAnimator.presenting = false
    return topSlideAnimator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if topSlideAnimator.interactive {
      topSlideAnimator.presenting = true
      return topSlideAnimator
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if topSlideAnimator.interactive {
      topSlideAnimator.presenting = false
      return topSlideAnimator
    }
    return nil
  }
}

//
//  DataHeaderViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-18.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class DataHeaderViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
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
  
  func update(withDate date: Date, timeRangeType: TimeRangeType, user: BKUser?) {
    
    if timeRangeType == .monthly {
      dateLabel.text = date.monthYearString()
    } else {
      dateLabel.text = date.yearString()
    }
    
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

// MARK: - View Controller Transitioning Delegate Methods
extension DataHeaderViewController: UIViewControllerTransitioningDelegate {

  func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentationAnimator.presenting = true
    return presentationAnimator
  }
  
  func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
    presentationAnimator.presenting = false
    return presentationAnimator
  }
  
  func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if presentationAnimator.interactive {
      presentationAnimator.presenting = true
      return presentationAnimator
    }
    return nil
  }
  
  func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
    
    if presentationAnimator.interactive {
      presentationAnimator.presenting = false
      return presentationAnimator
    }
    return nil
  }
}

//
//  TopLevelNavigationController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-11-18.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

class TopLevelNavigationController: TopLevelViewController {
  
  let TransitionDistance = Utilities.screenWidth
  
  @IBOutlet weak var backButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  
  @IBOutlet weak var currentView: UIView!
  @IBOutlet weak var nextView: UIView!
  @IBOutlet weak var previousView: UIView!
  
  @IBOutlet weak var currentViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var currentViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var nextViewTrailingConstraint: NSLayoutConstraint!
  @IBOutlet weak var previousViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var previousViewTrailingConstraint: NSLayoutConstraint!
  
  var currentViewController: UIViewController!
  var viewControllerStack: [UIViewController] = []
  
  var leftRecognizer: DirectionalPanGestureRecognizer!
  
  var detailColor = UIColor.white {
    didSet {
      backButton.tintColor = detailColor
      closeButton.tintColor = detailColor
    }
  }
  
  init(withRootViewController rootViewController: UIViewController & TopLevelNavigable) {
    super.init(nibName: "TopLevelNavigationController", bundle: nil)
    rootViewController.topLevelNavigationController = self
    currentViewController = rootViewController
    viewControllerStack.append(rootViewController)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override var childViewControllerForStatusBarStyle: UIViewController? {
    return currentViewController
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    leftRecognizer = DirectionalPanGestureRecognizer(target: self, action: #selector(handlePreviousDrag(_:)))
    leftRecognizer.gestureDirection = .StrictHorizontal
    leftRecognizer.delegate = self
    view.addGestureRecognizer(leftRecognizer)
    
    backButton.tintColor = detailColor
    backButton.alpha = 0.0
    
    closeButton.tintColor = detailColor
    closeButton.alpha = 1.0
    
    add(currentViewController, to: currentView)
    
    if let currentViewController = currentViewController as? TopLevelNavigable {
      currentViewController.willBecomeCurrentTopLevelNavigableViewController()
    }
    
    if !self.isDismissable {
      closeButton.isHidden = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func backButtonTapped() {
    pop()
  }
  
  @IBAction func closeButtonTapped() {
    if self.isDismissable {
      topLevelViewControllerDelegate?.topLevelViewControllerDismissed()
    }
  }
  
  func push(_ viewController: UIViewController & TopLevelNavigable) {
    
    viewController.topLevelNavigationController = self
    add(viewController, to: nextView)
    viewController.willBecomeCurrentTopLevelNavigableViewController()
    animateToNextView(withDistanceToTravel: TransitionDistance, andVelocity: 0) {
      self.add(self.currentViewController, to: self.previousView)
      self.currentViewController = viewController
      self.add(self.currentViewController, to: self.currentView)
      self.repositionViews()
      self.viewControllerStack.append(viewController)
    }
  }
  
  func pop() {
    
    viewControllerStack.removeLast()
    if let viewController = viewControllerStack.last {
      (viewController as! TopLevelNavigable).willBecomeCurrentTopLevelNavigableViewController()
      animateToPreviousView(withDistanceToTravel: TransitionDistance, andVelocity: 0, completion: {
        self.currentViewController.removeFromContainerView()
        self.currentViewController = viewController
        self.add(self.currentViewController, to: self.currentView)
        self.repositionViews()
      })
    }
  }
  
  @objc func handlePreviousDrag(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    
    if viewControllerStack.count == 1 {
      return
    }
    
    if recognizer.state == .began {
      
      view.endEditing(true)
      view.isUserInteractionEnabled = false
      
      currentViewController?.view.isUserInteractionEnabled = false
      
      previousViewLeadingConstraint.constant = -TransitionDistance
      previousViewTrailingConstraint.constant = TransitionDistance
      nextViewLeadingConstraint.constant = TransitionDistance
      nextViewTrailingConstraint.constant = -TransitionDistance
      view.layoutIfNeeded()
      
    } else if recognizer.state == .changed {
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      
      currentViewLeadingConstraint.constant = progress * TransitionDistance
      currentViewTrailingConstraint.constant = -progress * TransitionDistance
      
      previousViewLeadingConstraint.constant = -TransitionDistance + (progress * TransitionDistance)
      previousViewTrailingConstraint.constant = TransitionDistance - (progress * TransitionDistance)
      
      if viewControllerStack.count == 2 {
        backButton.alpha = 1.0 - progress
        closeButton.alpha = progress
      }
      
      view.layoutIfNeeded()
      
    } else if recognizer.state == .ended {
      
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
      
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      let velocity = recognizer.velocity(in: view).x
      
      if (progress > 0.5 || velocity > 300) && velocity > -300 {
        let distanceToTravel = (1.0 - progress) * TransitionDistance
        
        viewControllerStack.removeLast()
        if let viewController = viewControllerStack.last {
          (viewController as! TopLevelNavigable).willBecomeCurrentTopLevelNavigableViewController()
          animateToPreviousView(withDistanceToTravel: distanceToTravel, andVelocity: velocity, completion: {
            self.currentViewController.removeFromContainerView()
            self.currentViewController = viewController
            self.add(self.currentViewController, to: self.currentView)
            self.repositionViews()
          })
        }
        
      } else {
        let distanceToTravel = progress * TransitionDistance
        animateToCurrentView(withDistanceToTravel: distanceToTravel, andVelocity: -velocity)
      }
      
    } else {
      view.isUserInteractionEnabled = true
      currentViewController?.view.isUserInteractionEnabled = true
    }
  }
  
  private func animateToNextView(withDistanceToTravel distanceToTravel: CGFloat, andVelocity velocity: CGFloat, completion: (() -> ())?) {
    self.view.layoutIfNeeded()
    nextViewLeadingConstraint.constant = 0
    nextViewTrailingConstraint.constant = 0
    currentViewLeadingConstraint.constant = -TransitionDistance
    currentViewTrailingConstraint.constant = TransitionDistance
    
    // PROBLEM: 10.99
    var springVelocity = velocity / max(distanceToTravel, 1.0)
    
    if springVelocity > 10.86 && springVelocity <= 11.0 {
      springVelocity = 10.86
    }
    
    if springVelocity > 11.0 && springVelocity < 11.14 {
      springVelocity = 11.14
    }
    
    UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      
      self.nextView.alpha = 1.0
      self.backButton.alpha = 1.0
      self.closeButton.alpha = 0.0
      self.view.layoutIfNeeded()
      
    }, completion: { (finished: Bool) -> Void in
      if let completion = completion {
        completion()
      }
    })
  }
  
  private func animateToCurrentView(withDistanceToTravel distanceToTravel: CGFloat, andVelocity velocity: CGFloat) {
    self.view.layoutIfNeeded()
    currentViewLeadingConstraint.constant = 0
    currentViewTrailingConstraint.constant = 0
    previousViewLeadingConstraint.constant = -TransitionDistance
    previousViewTrailingConstraint.constant = TransitionDistance
    nextViewLeadingConstraint.constant = TransitionDistance
    nextViewTrailingConstraint.constant = -TransitionDistance
    
    // PROBLEM: 10.99
    var springVelocity = velocity / max(distanceToTravel, 1.0)
    
    if springVelocity > 10.86 && springVelocity <= 11.0 {
      springVelocity = 10.86
    }
    
    if springVelocity > 11.0 && springVelocity < 11.14 {
      springVelocity = 11.14
    }
    
    UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      
      self.view.layoutIfNeeded()
      self.backButton.alpha = 1.0
      self.closeButton.alpha = 0.0
      
    }, completion: { (finished: Bool) -> Void in
      
    })
  }
  
  private func animateToPreviousView(withDistanceToTravel distanceToTravel: CGFloat, andVelocity velocity: CGFloat, completion: (() -> ())?) {
    
    currentViewTrailingConstraint.constant = -TransitionDistance
    currentViewLeadingConstraint.constant = TransitionDistance
    previousViewTrailingConstraint.constant = 0
    previousViewLeadingConstraint.constant = 0
    
    //PROBLEM: 10.99
    var springVelocity = velocity / max(distanceToTravel, 1.0)
    
    if springVelocity > 10.86 && springVelocity <= 11.0 {
      springVelocity = 10.86
    }
    
    if springVelocity > 11.0 && springVelocity < 11.14 {
      springVelocity = 11.14
    }
    
    UIView.animate(withDuration: 0.38, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: springVelocity, options: .allowUserInteraction, animations: { () -> Void in
      self.view.layoutIfNeeded()
      
      self.previousView.alpha = 1.0
      if self.viewControllerStack.count == 1 {
        self.backButton.alpha = 0.0
        self.closeButton.alpha  = 1.0
      }
      
    }, completion: { (finished: Bool) -> Void in
      if let completion = completion {
        completion()
      }
    })
  }
  
  func repositionViews() {
    
    currentViewLeadingConstraint.constant = 0
    currentViewTrailingConstraint.constant = 0
    previousViewLeadingConstraint.constant = -TransitionDistance
    previousViewTrailingConstraint.constant = TransitionDistance
    nextViewLeadingConstraint.constant = TransitionDistance
    nextViewTrailingConstraint.constant = -TransitionDistance
    view.layoutIfNeeded()
    setNeedsStatusBarAppearanceUpdate()
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    if gestureRecognizer == leftRecognizer {
      
      let directionalGestureRecognizer = gestureRecognizer as! DirectionalPanGestureRecognizer
      if directionalGestureRecognizer.velocity(in: view).x > 0 {
        return true
      } else {
        return false
      }
    } else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
  }
}

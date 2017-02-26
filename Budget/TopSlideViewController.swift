//
//  TopSlideViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-02-19.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol TopSlideDelegate: class {
  func shouldDismissTopSlideViewController()
}

class TopSlideViewController: UIViewController {
  
  weak var topSlideDelegate: TopSlideDelegate?
  weak var interactivePresenter: InteractivePresenter?
  
  @IBOutlet weak var containerView: UIView!
  @IBOutlet weak var containerViewTopConstraint: NSLayoutConstraint!
  
  var viewController: UIViewController?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if let viewController = viewController {
      add(viewController, to: containerView)
    }
    
    containerView.layer.cornerRadius = 8.0
    containerView.clipsToBounds = true
    containerView.layer.allowsEdgeAntialiasing = true
    
    let panGestureRecognizer = OneWayPanGestureRecognizer(target: self, action: #selector(handleDrag(recognizer:)))
    panGestureRecognizer.direction = .up
    view.addGestureRecognizer(panGestureRecognizer)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func dismissButtonTapped() {
    topSlideDelegate?.shouldDismissTopSlideViewController()
  }
  
  func handleDrag(recognizer: UIPanGestureRecognizer) {
    
    if recognizer.state == .began {
      view.endEditing(true)
      interactivePresenter?.interactiveDismissalBegan()
      
    } else if recognizer.state == .changed {
      var progress = -recognizer.translation(in: view).y / (96.0 + containerView.frame.size.height)
      if progress < 0.0 {
        progress = progress / (4.0 * (1.0 - progress))
      }
      
      interactivePresenter?.interactiveDismissalChanged(withProgress: progress)
      
      let xTranslation = recognizer.translation(in: view).x
      var xTranslationPercent = xTranslation / 100.0
      
      let yPosition = recognizer.location(in: containerView).y
      let containerViewCenterY = (containerView.frame.height / 2.0)
      
      let normalizedYPosition = (yPosition - containerViewCenterY) / containerViewCenterY * -1.0
      xTranslationPercent *= normalizedYPosition
      
      containerView.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI_4 / 10.0) * xTranslationPercent)
      
    } else if recognizer.state == .ended {
      var progress = -recognizer.translation(in: view).y / (96.0 + containerView.frame.size.height)
      progress = min(1.0, max(0.0, progress))
      var velocity = recognizer.velocity(in: view).y
      
      if (progress > 0.5 || velocity < -300) && velocity < 300 {
        var distanceToTravel = (1.0 - progress) * (96.0 + containerView.frame.size.height)
        if distanceToTravel < 0 {
          distanceToTravel *= -1.0
          velocity *= -1
        }
        
        interactivePresenter?.interactiveDismissalFinished(withDistanceToTravel: distanceToTravel, velocity: velocity)
        
        UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { () -> Void in
          self.containerView.transform = CGAffineTransform.identity
        }, completion: nil)
        
      } else {
        var distanceToTravel = progress * (96.0 + containerView.frame.size.height)
        if distanceToTravel < 0 {
          distanceToTravel *= -1.0
          velocity *= -1
        }
        
        interactivePresenter?.interactiveDismissalCanceled(withDistanceToTravel: distanceToTravel, velocity: -velocity)
        
        UIView.animate(withDuration: 0.45, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: [], animations: { () -> Void in
          self.containerView.transform = CGAffineTransform.identity
        }, completion: nil)
      }
    }
  }
}

//
//  SettingsViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-03-25.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

protocol SettingsDelegate: class {
  func shouldDismissSettings()
}

class SettingsViewController: TopLevelViewController, InteractivePresenter, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  let TransitionDistance = Utilities.screenWidth
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  weak var settingsDelegate: SettingsDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var detailActionButton: UIButton!
  @IBOutlet weak var detailContainerView: UIView!
  
  @IBOutlet weak var tableViewLeadingConstraint: NSLayoutConstraint!
  @IBOutlet weak var tableViewTrailingConstraint: NSLayoutConstraint!
  
  let settingsArray = ["Categories", "Users"]
  var selectedIndexPath: IndexPath?
  
  var categoryManagementViewController: CategoryManagementViewController?
  //var userManagementViewController: UserManagementViewController?
  
  var currentDetailViewController: UIViewController?
  
  var leftRecognizer: DirectionalPanGestureRecognizer!
  
  var isDetailViewVisible = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    navigationController?.navigationBar.isHidden = true
    
    headerLabel.textColor = UIColor.text
    closeButton.tintColor = UIColor.text
    detailActionButton.tintColor = UIColor.text
    
    tableView.register(UINib(nibName: "SettingsCell", bundle: nil), forCellReuseIdentifier: "SettingsCell")
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 76))
    
    leftRecognizer = DirectionalPanGestureRecognizer(target: self, action: #selector(handlePreviousDrag(_:)))
    leftRecognizer.gestureDirection = .StrictHorizontal
    leftRecognizer.delegate = self
    detailContainerView.addGestureRecognizer(leftRecognizer)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    
  }
  
  @IBAction func closeButtonTapped() {
    if (isDetailViewVisible) {
      dismissDetailViewController()
    } else {
      settingsDelegate?.shouldDismissSettings()
    }
  }
  
  @IBAction func detailActionButtonTapped() {
    
    if currentDetailViewController == categoryManagementViewController {
      categoryManagementViewController?.presentCategoryCreationView()
    }
    
  }
  
  func present(detailViewController: UIViewController) {
    
    currentDetailViewController = detailViewController
    closeButton.setImage(UIImage(named: "leftArrowButton"), for: .normal)
    
    if detailViewController == categoryManagementViewController {
      headerLabel.text = "Categories"
    }
    
    add(detailViewController, to: detailContainerView)
    
    tableViewLeadingConstraint.constant = -Utilities.screenWidth
    tableViewTrailingConstraint.constant = Utilities.screenWidth
    
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { 
      self.view.layoutIfNeeded()
      self.detailActionButton.alpha = 1.0
    }, completion: nil)
    
    isDetailViewVisible = true
  }
  
  func dismissDetailViewController() {
    
    currentDetailViewController = nil
    closeButton.setImage(UIImage(named: "closeButton"), for: .normal)
    headerLabel.text = "Settings"
    
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    tableViewLeadingConstraint.constant = 0
    tableViewTrailingConstraint.constant = 0
    
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: { 
      self.view.layoutIfNeeded()
      self.detailActionButton.alpha = 0.0
    }) { (success) in
      if let categoryManagementViewController = self.categoryManagementViewController {
        categoryManagementViewController.removeFromContainerView()
      }
    }
    
    isDetailViewVisible = false
  }
  
  
  @objc func handlePreviousDrag(_ recognizer: UIScreenEdgePanGestureRecognizer) {
    
    if recognizer.state == .began {
      
      view.endEditing(true)
      
      detailContainerView.isUserInteractionEnabled = false
      view.layoutIfNeeded()
      
    } else if recognizer.state == .changed {
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      
      tableViewLeadingConstraint.constant = -TransitionDistance + (progress * TransitionDistance)
      tableViewTrailingConstraint.constant = TransitionDistance - (progress * TransitionDistance)
      
      view.layoutIfNeeded()
      
    } else if recognizer.state == .ended {
      
      detailContainerView.isUserInteractionEnabled = true
      
      var progress = recognizer.translation(in: view).x / TransitionDistance
      progress = min(1.0, max(0.0, progress))
      let velocity = recognizer.velocity(in: view).x
      
      if (progress > 0.5 || velocity > 300) && velocity > -300 {
        let distanceToTravel = (1.0 - progress) * TransitionDistance
        
        tableViewLeadingConstraint.constant = 0
        tableViewTrailingConstraint.constant = 0
        
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
          self.detailActionButton.alpha = 0.0
        }, completion: { (success) in
          if let categoryManagementViewController = self.categoryManagementViewController {
            categoryManagementViewController.removeFromContainerView()
          }
        })
        
        if let selectedIndexPath = selectedIndexPath {
          tableView.deselectRow(at: selectedIndexPath, animated: true)
        }
        
        closeButton.setImage(UIImage(named: "closeButton"), for: .normal)
        currentDetailViewController = nil
        headerLabel.text = "Settings"
        isDetailViewVisible = false
        
      } else {
        let distanceToTravel = progress * TransitionDistance
        self.view.layoutIfNeeded()
        tableViewLeadingConstraint.constant = -TransitionDistance
        tableViewTrailingConstraint.constant = TransitionDistance
        
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
        }, completion: nil)
      }
      
    } else {
      detailContainerView.isUserInteractionEnabled = true
    }
  }
  
  override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    
    if gestureRecognizer == leftRecognizer {
      let gestureRecognizer = gestureRecognizer as! DirectionalPanGestureRecognizer
      if gestureRecognizer == leftRecognizer && gestureRecognizer.velocity(in: view).x > 0 {
        return true
      } else {
        return false
      }
    } else {
      return super.gestureRecognizerShouldBegin(gestureRecognizer)
    }
  }
}

// MARK: - Table View Delegate Methods
extension SettingsViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if indexPath.row == 0 {
      
      categoryManagementViewController = CategoryManagementViewController(nibName: "CategoryManagementViewController", bundle: nil)
      present(detailViewController: categoryManagementViewController!)
      
    } else if indexPath.row == 1 {
      
    }
    
    selectedIndexPath = indexPath
  }
}

// MARK: - Table View Data Source Methods
extension SettingsViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return settingsArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell") as! SettingsCell
    cell.titleLabel.text = settingsArray[indexPath.row]
    return cell
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension SettingsViewController: UIViewControllerTransitioningDelegate {
  
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

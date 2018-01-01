//
//  CategoryManagementViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class CategoryManagementViewController: UIViewController, InteractivePresenter, TopLevelNavigable {
  
  var topLevelNavigationController: TopLevelNavigationController?
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var createButton: UIButton!
  
  var categoryArray = [BKCategory]()
  var selectedIndexPath: IndexPath?
  
  override func viewWillAppear(_ animated: Bool) {
    print("view will appear")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    createButton.tintColor = .text
    
    tableView.register(UINib(nibName: "CategoryManagementCell", bundle: nil), forCellReuseIdentifier: "CategoryManagementCell")
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.tableView.reloadData()
    }
    
    tableView.tableFooterView = UIView(frame: CGRect())
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  @IBAction func createButtonTapped() {
    let categoryDetailViewController = CategoryDetailViewController(nibName: "CategoryDetailViewController", bundle: nil)
    categoryDetailViewController.delegate = self
    let topSlideViewController = TopSlideViewController(presenting: categoryDetailViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  func presentCategoryDetailView(forCategory category: BKCategory) {
    let categoryDetailViewController = CategoryDetailViewController(nibName: "CategoryDetailViewController", bundle: nil)
    categoryDetailViewController.delegate = self
    categoryDetailViewController.category = category
    let topSlideViewController = TopSlideViewController(presenting: categoryDetailViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  // MARK: - Interactive Presenter Methods
  func interactivePresentationDismissed() {
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
}

// MARK: - Table View Data Source Methods
extension CategoryManagementViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoryArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "CategoryManagementCell") as! CategoryManagementCell
    cell.category = categoryArray[indexPath.row]
    return cell
  }
}

// MARK: - Table View Delegate Methods
extension CategoryManagementViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    selectedIndexPath = indexPath
    let category = categoryArray[indexPath.row]
    presentCategoryDetailView(forCategory: category)
  }
}

// MARK: - Category Detail Delegate Methods
extension CategoryManagementViewController: CategoryDetailDelegate {
  
  func shouldDismissCategoryDetailView() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
  
  func didCreateNewCategory() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.tableView.reloadData()
    }
  }
  
  func didUpdateCategory() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.tableView.reloadData()
    }
  }
  
  func didDeleteCategory() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.tableView.reloadData()
    }
  }
}

// MARK: - Top Slide Delegate Methods
extension CategoryManagementViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
    if let selectedIndexPath = selectedIndexPath {
      tableView.deselectRow(at: selectedIndexPath, animated: true)
    }
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension CategoryManagementViewController: UIViewControllerTransitioningDelegate {
  
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

//
//  ExpenseDataViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-04.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol ExpenseDataDelegate: class {
  func shouldDismissExpenseData()
  func didFinishLoadingExpenseData()
}

class ExpenseDataViewController: UIViewController, TableViewController, InteractivePresenter, TopLevelViewControllerDelegate {
  
  var presentationAnimator: PresentationAnimator = TopLayerAnimator()
  
  weak var expenseDataDelegate: ExpenseDataDelegate?
  
  var dataHeaderViewController: DataHeaderViewController?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerView: UIView!
  @IBOutlet weak var headerLabel: UILabel!
  @IBOutlet weak var closeButton: UIButton!
  @IBOutlet weak var headerViewHeightConstraint: NSLayoutConstraint!
  
  var nextPageActivityIndicatorView: UIActivityIndicatorView!
  var lastPageFooterLabel: UILabel!
  
  var expenseArray = [BKExpense]()
  var date: Date = Date()
  var timeRangeType: TimeRangeType = .monthly
  var category: BKCategory?
  var userFilter: BKUser? {
    didSet {
      if viewIsLoaded {
        dataHeaderViewController?.user = userFilter
        updateData()
      }
    }
  }
  var shouldIncludeDataHeader: Bool = true
  var currentPage: Int = 0
  var currentlyLoading: Bool = false
  var hasNextPage: Bool = true
  var viewIsLoaded = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    NotificationCenter.default.addObserver(self, selector: #selector(updateData), name: .updateDataView, object: nil)
    
    if shouldIncludeDataHeader {
      dataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
      dataHeaderViewController!.date = date
      dataHeaderViewController!.user = userFilter
      dataHeaderViewController!.timeRangeType = timeRangeType
      add(dataHeaderViewController!, to: headerView)
    } else {
      
      if let category = category {
        
        headerLabel.text = category.name
        headerLabel.textColor = category.color
        closeButton.tintColor = category.color
        
        headerViewHeightConstraint.constant = 44
        view.layoutIfNeeded()
        
      } else if let userFilter = userFilter {
        
        headerLabel.text = userFilter.name
        
        headerViewHeightConstraint.constant = 44
        view.layoutIfNeeded()
        
      } else {
        closeButton.isHidden = true
        headerViewHeightConstraint.constant = 0
        view.layoutIfNeeded()
      }
    }
    
    tableView.register(UINib(nibName: "ExpenseDataCell", bundle: nil), forCellReuseIdentifier: "ExpenseDataCell")
    
    setUpFooterView()
    updateData()
    
    viewIsLoaded = true
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if presentingViewController == nil {
      closeButton.isHidden = true
    } else {
      closeButton.isHidden = false
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Private Utility Methods
  
  func setUpFooterView() {
    
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 76))
    
    nextPageActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    nextPageActivityIndicatorView.translatesAutoresizingMaskIntoConstraints = false
    nextPageActivityIndicatorView.color = category?.color
    tableView.tableFooterView?.addSubview(nextPageActivityIndicatorView)
    
    let activityViewCenterXConstraint = NSLayoutConstraint(item: nextPageActivityIndicatorView, attribute: .centerX, relatedBy: .equal, toItem: tableView.tableFooterView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    
    let activityViewCenterYConstraint = NSLayoutConstraint(item: nextPageActivityIndicatorView, attribute: .centerY, relatedBy: .equal, toItem: tableView.tableFooterView, attribute: .centerY, multiplier: 1.0, constant: -8.0)
    
    tableView.tableFooterView?.addConstraint(activityViewCenterXConstraint)
    tableView.tableFooterView?.addConstraint(activityViewCenterYConstraint)
    
    lastPageFooterLabel = UILabel()
    lastPageFooterLabel.translatesAutoresizingMaskIntoConstraints = false
    lastPageFooterLabel.textColor = category?.color.withAlphaComponent(0.2)
    lastPageFooterLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFont.Weight.medium)
    lastPageFooterLabel.text = "---"
    lastPageFooterLabel.isHidden = true
    tableView.tableFooterView?.addSubview(lastPageFooterLabel)
    
    let footerViewCenterXConstraint = NSLayoutConstraint(item: lastPageFooterLabel, attribute: .centerX, relatedBy: .equal, toItem: tableView.tableFooterView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    
    let footerViewCenterYConstraint = NSLayoutConstraint(item: lastPageFooterLabel, attribute: .centerY, relatedBy: .equal, toItem: tableView.tableFooterView, attribute: .centerY, multiplier: 1.0, constant: -8.0)
    
    tableView.tableFooterView?.addConstraint(footerViewCenterXConstraint)
    tableView.tableFooterView?.addConstraint(footerViewCenterYConstraint)
  }
  
  // MARK: - Action Methods
  
  @IBAction func closeButtonTapped() {
    expenseDataDelegate?.shouldDismissExpenseData()
  }
  
  func loadNextPage() {
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = date.startAndEndOfMonth()
    } else {
      dates = date.startAndEndOfYear()
    }
    
    nextPageActivityIndicatorView.alpha = 0.0
    nextPageActivityIndicatorView.startAnimating()
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: { 
      self.nextPageActivityIndicatorView.alpha = 1.0
    }, completion: nil)
    
    BKSharedBasicRequestClient.getExpenses(forUserID: userFilter?.cloudID, categoryID: category?.cloudID, startDate: dates.startDate, endDate: dates.endDate, page: currentPage + 1) { (success, expenseArray) in
      
      self.nextPageActivityIndicatorView.stopAnimating()
      
      guard success, let expenseArray = expenseArray else {
        print("failed to get expenses")
        self.currentlyLoading = false
        return
      }
      
      if (expenseArray.count > 0) {
        self.currentPage += 1
        self.nextPageActivityIndicatorView.startAnimating()
        self.hasNextPage = true
      } else {
        self.nextPageActivityIndicatorView.stopAnimating()
        self.hasNextPage = false
      }
      
      self.expenseArray += expenseArray
      self.tableView.reloadData()
      self.currentlyLoading = false
      
      if self.hasNextPage {
        self.lastPageFooterLabel.isHidden = true
      } else {
        self.lastPageFooterLabel.isHidden = false
      }
    }
  }
  
  func presentExpenseEntryView(withExpense expense: BKExpense) {
    
    let expenseEntryViewController = ExpenseEntryViewController(nibName: "ExpenseEntryViewController", bundle: nil)
    expenseEntryViewController.existingExpense = expense
    expenseEntryViewController.interactivePresenter = self
    expenseEntryViewController.topLevelViewControllerDelegate = self
    expenseEntryViewController.expenseEntryDelegate = self
    expenseEntryViewController.transitioningDelegate = self
    expenseEntryViewController.modalPresentationStyle = .custom
    
    presentationAnimator.initialCenter = CGPoint(x: Utilities.screenWidth / 2, y: Utilities.screenHeight * 1.5)
    present(expenseEntryViewController, animated: true)
  }
  
  func interactivePresentationDismissed() {
    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedRow, animated: true)
    }
  }
  
  func topLevelViewControllerDismissed(_ topLevelViewController: TopLevelViewController) {
    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedRow, animated: true)
    }
    dismiss(animated: true)
  }
}

extension ExpenseDataViewController: ExpenseEntryDelegate {
  
  func expenseEntered() {
    if let selectedRow = tableView.indexPathForSelectedRow {
      tableView.deselectRow(at: selectedRow, animated: true)
    }
    self.updateData()
    dismiss(animated: true)
  }
}

// MARK: - Data Displaying Protocol Methods
extension ExpenseDataViewController: DataDisplaying {
  
  @objc func updateData() {
    
    currentPage = 0
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = date.startAndEndOfMonth()
    } else {
      dates = date.startAndEndOfYear()
    }
    
    BKSharedBasicRequestClient.getCategories { (success, categoryArray) in
      
      guard success, categoryArray != nil else {
        print("failed to get categories")
        return
      }
      
      BKSharedBasicRequestClient.getExpenses(forUserID: self.userFilter?.cloudID, categoryID: self.category?.cloudID, startDate: dates.startDate, endDate: dates.endDate, page: self.currentPage) { (success, expenseArray) in
        
        guard success, let expenseArray = expenseArray else {
          print("failed to get expenses")
          return
        }
        
        self.expenseArray = expenseArray
        self.tableView.reloadData()
        self.expenseDataDelegate?.didFinishLoadingExpenseData()
        
        if self.expenseArray.count < 25 {
          self.hasNextPage = false
          self.lastPageFooterLabel.isHidden = false
        } else {
          self.hasNextPage = true
          self.lastPageFooterLabel.isHidden = true
        }
      }
    }
  }
  
  func fadeOut(completion: (() -> ())?) {
    tableView.alpha = 1.0
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
      self.tableView.alpha = 0.0
    }) { (success) in
      if let completion = completion {
        completion()
      }
    }
  }
  
  func fadeIn(completion: (() -> ())?) {
    tableView.alpha = 0.0
    UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: {
      self.tableView.alpha = 1.0
    }) { (success) in
      if let completion = completion {
        completion()
      }
    }
  }
}

// MARK: - Table View Delegate Methods
extension ExpenseDataViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let expense = self.expenseArray[indexPath.row]
    self.presentExpenseEntryView(withExpense: expense)
  }
}

// MARK: - Table View Data Source Methods
extension ExpenseDataViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return expenseArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseDataCell") as! ExpenseDataCell
    cell.expense = expenseArray[indexPath.row]
    return cell
  }
}

// MARK: - Scroll View Delegate Methods
extension ExpenseDataViewController: UIScrollViewDelegate {
  func scrollViewDidScroll(_ scrollView: UIScrollView) {
    if currentlyLoading || !hasNextPage {
      return
    }
    let currentOffset = scrollView.contentOffset.y
    let currentContentHeight = scrollView.contentSize.height
    let scrollViewHeight = scrollView.frame.height
    let difference = currentContentHeight - scrollViewHeight
    
    if currentOffset >= difference - 32 {
      currentlyLoading = true
      loadNextPage()
    }
  }
}

extension ExpenseDataViewController: UIViewControllerTransitioningDelegate {
  
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

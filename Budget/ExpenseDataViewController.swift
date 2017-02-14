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

class ExpenseDataViewController: UIViewController, TableViewController {
  
  weak var expenseDataDelegate: ExpenseDataDelegate?
  
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
  var user: BKUser?
  var shouldIncludeDataHeader: Bool = true
  var currentPage: Int = 0
  var currentlyLoading: Bool = false
  var hasNextPage: Bool = true
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    if shouldIncludeDataHeader {
      let dataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
      dataHeaderViewController.date = date
      dataHeaderViewController.timeRangeType = timeRangeType
      add(dataHeaderViewController, to: headerView)
    } else {
      
      if let category = category {
        
        headerLabel.text = category.name
        headerLabel.textColor = category.color
        closeButton.setTitleColor(category.color, for: .normal)
        
        headerViewHeightConstraint.constant = 44
        view.layoutIfNeeded()
        
      } else if let user = user {
        
        headerLabel.text = user.name
        
        headerViewHeightConstraint.constant = 44
        view.layoutIfNeeded()
        
      } else {
        headerViewHeightConstraint.constant = 0
        view.layoutIfNeeded()
      }
    }
    
    tableView.register(UINib(nibName: "ExpenseDataCell", bundle: nil), forCellReuseIdentifier: "ExpenseDataCell")
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
    lastPageFooterLabel.font = UIFont.systemFont(ofSize: 12.0, weight: UIFontWeightMedium)
    lastPageFooterLabel.text = "Nothing else to see here."
    lastPageFooterLabel.isHidden = true
    tableView.tableFooterView?.addSubview(lastPageFooterLabel)
    
    let footerViewCenterXConstraint = NSLayoutConstraint(item: lastPageFooterLabel, attribute: .centerX, relatedBy: .equal, toItem: tableView.tableFooterView, attribute: .centerX, multiplier: 1.0, constant: 0.0)
    
    let footerViewCenterYConstraint = NSLayoutConstraint(item: lastPageFooterLabel, attribute: .centerY, relatedBy: .equal, toItem: tableView.tableFooterView, attribute: .centerY, multiplier: 1.0, constant: -8.0)
    
    tableView.tableFooterView?.addConstraint(footerViewCenterXConstraint)
    tableView.tableFooterView?.addConstraint(footerViewCenterYConstraint)
    
    updateData()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if presentingViewController == nil {
      closeButton.isHidden = true
    } else {
      closeButton.isHidden = false
    }
    
    if Utilities.dataViewNeedsUpdate() {
      updateData()
    } else {
      tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
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
    
    BKSharedBasicRequestClient.getExpenses(forUserID: user?.cloudID, categoryID: category?.cloudID, startDate: dates.startDate, endDate: dates.endDate, page: currentPage + 1) { (success, expenseArray) in
      
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
}

// MARK: - Data Displaying Protocol Methods
extension ExpenseDataViewController: DataDisplaying {
  
  func updateData() {
    
    currentPage = 0
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = date.startAndEndOfMonth()
    } else {
      dates = date.startAndEndOfYear()
    }
    
    BKSharedBasicRequestClient.getExpenses(forUserID: user?.cloudID, categoryID: category?.cloudID, startDate: dates.startDate, endDate: dates.endDate, page: currentPage) { (success, expenseArray) in
      
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
    print("\(currentOffset)")
    print("content height: \(currentContentHeight)")
    print("scroll height: \(scrollViewHeight)")
    print("difference: \(difference)")
    
    if currentOffset >= difference - 32 {
      currentlyLoading = true
      loadNextPage()
    }
  }
}

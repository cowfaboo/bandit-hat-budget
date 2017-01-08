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

class ExpenseDataViewController: UIViewController {
  
  weak var expenseDataDelegate: ExpenseDataDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var headerView: UIView!
  
  @IBOutlet weak var closeButton: UIButton!
  
  var expenseArray = [BKExpense]()
  var date: Date = Date()
  var timeRangeType: TimeRangeType = .monthly
  var category: BKCategory?
  var user: BKUser?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
    dataHeaderViewController.date = date
    dataHeaderViewController.timeRangeType = timeRangeType
    add(dataHeaderViewController, to: headerView)

    
    tableView.register(UINib(nibName: "ExpenseDataCell", bundle: nil), forCellReuseIdentifier: "ExpenseDataCell")
    tableView.tableFooterView = UIView(frame: CGRect(x: 0, y: 0, width: tableView.frame.size.width, height: 76))
    
    fetchExpenses()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if presentingViewController == nil {
      closeButton.isHidden = true
    } else {
      closeButton.isHidden = false
    }
    
    if Utilities.dataViewNeedsUpdate() {
      fetchExpenses()
    } else {
      tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func fetchExpenses() {
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = Utilities.getStartAndEndOfMonth(from: date)
    } else {
      dates = Utilities.getStartAndEndOfYear(from: date)
    }
    
    BKSharedBasicRequestClient.getExpenses(forUserID: user?.cloudID, categoryID: category?.cloudID, startDate: dates.startDate, endDate: dates.endDate) { (success, expenseArray) in
      
      guard success, let expenseArray = expenseArray else {
        print("failed to get expenses")
        return
      }
      
      self.expenseArray = expenseArray
      self.tableView.reloadData()
      self.expenseDataDelegate?.didFinishLoadingExpenseData()
    }
  }
  
  @IBAction func closeButtonTapped() {
    expenseDataDelegate?.shouldDismissExpenseData()
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

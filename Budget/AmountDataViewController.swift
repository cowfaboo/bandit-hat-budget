//
//  AmountDataViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class AmountDataViewController: UIViewController {
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var dateLabel: UILabel!
  
  var amountArray = [BKAmount]()
  var date: Date = Date()
  var timeRangeType: TimeRangeType = .monthly
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    if timeRangeType == .monthly {
      dateLabel.text = Utilities.getMonthYearString(from: date)
    } else {
      dateLabel.text = Utilities.getYearString(from: date)
    }
    
    
    fetchAmounts()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if Utilities.dataViewNeedsUpdate() {
      fetchAmounts()
    } else {
      tableView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func fetchAmounts() {
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = Utilities.getStartAndEndOfMonth(from: date)
    } else {
      dates = Utilities.getStartAndEndOfYear(from: date)
    }
    
    BKSharedBasicRequestClient.getAmountsByCategory(forUserID: Settings.currentUserID(), startDate: dates.startDate, endDate: dates.endDate) { (success, amountArray) in
      
      guard success, let amountArray = amountArray else {
        print("failed to get amounts")
        return
      }
      
      self.amountArray = amountArray
      self.tableView.reloadData()
    }
  }
}

// MARK: - Table View Delegate Methods
extension AmountDataViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    let amount = amountArray[indexPath.row]
    let category = BKCategory.fetchCategory(withCloudID: amount.categoryID!)
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    expenseDataViewController.expenseDataDelegate = self
    expenseDataViewController.category = category
    
    if timeRangeType == .monthly {
      expenseDataViewController.startDate = Utilities.getStartAndEndOfMonth(from: date).startDate
      expenseDataViewController.endDate = Utilities.getStartAndEndOfMonth(from: date).endDate
    } else {
      expenseDataViewController.startDate = Utilities.getStartAndEndOfYear(from: date).startDate
      expenseDataViewController.startDate = Utilities.getStartAndEndOfYear(from: date).endDate
    }
    
    present(expenseDataViewController, animated: true, completion: nil)
  }
}

// MARK: - Table View Data Source Methods
extension AmountDataViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return amountArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let amount = amountArray[indexPath.row]
    let category = BKCategory.fetchCategory(withCloudID: amount.categoryID!)
    
    if let category = category {
      
      var budget: Float
      if timeRangeType == .monthly {
        budget = category.monthlyBudget
      } else {
        budget = category.monthlyBudget * 12
      }
      
      cell.textLabel?.text = "\(category.name) - \(amountArray[indexPath.row].amount.dollarAmount) / \(budget.dollarAmount)"
    } else {
      cell.textLabel?.text = "Unknown Category - \(amountArray[indexPath.row].amount.dollarAmount)"
    }
    
    return cell
  }
}

// MARK: - Expense List Delegate Methods
extension AmountDataViewController: ExpenseDataDelegate {
  
  func shouldDismissExpenseData() {
    dismiss(animated: true, completion: nil)
  }
}

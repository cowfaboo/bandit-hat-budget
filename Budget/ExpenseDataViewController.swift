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
}

class ExpenseDataViewController: UIViewController {
  
  weak var expenseDataDelegate: ExpenseDataDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var closeButton: UIButton!
  
  var expenseArray = [BKExpense]()
  var startDate: Date?
  var endDate: Date?
  var category: BKCategory?
  var user: BKUser?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
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
    
    BKSharedBasicRequestClient.getExpenses(forUserID: user?.cloudID, categoryID: category?.cloudID, startDate: startDate, endDate: endDate) { (success, expenseArray) in
      
      guard success, let expenseArray = expenseArray else {
        print("failed to get expenses")
        return
      }
      
      self.expenseArray = expenseArray
      self.tableView.reloadData()
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
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    let expense = expenseArray[indexPath.row]
    
    cell.textLabel?.text = "\(expense.name) - \(expense.amount.dollarAmount)"
    
    return cell
  }
}

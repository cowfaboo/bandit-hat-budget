//
//  ExpenseEntryViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol ExpenseEntryDelegate: class {
  func expenseEntryDismissed()
}

class ExpenseEntryViewController: UIViewController {
  
  weak var expenseEntryDelegate: ExpenseEntryDelegate?
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var categoryPickerView: UIPickerView!
  
  var categoryArray = [BKCategory]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.categoryPickerView.reloadAllComponents()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Action Methods
  
  @IBAction func dismissButtonTapped() {
    expenseEntryDelegate?.expenseEntryDismissed()
  }
  
  @IBAction func addExpenseButtonTapped() {
    
    guard let name = nameTextField.text, name.characters.count > 0 else {
      print("no name entered")
      return
    }
    
    guard let amountString = amountTextField.text, amountString.characters.count > 0 else {
      print("no amount entered")
      return
    }
    
    guard let amount = Float(amountString) else {
      print("invalid amount entered")
      return
    }
    
    let userID = Settings.currentUserID()
    let category = categoryArray[categoryPickerView.selectedRow(inComponent: 0)]
    
    BKSharedBasicRequestClient.createExpense(withName: name, amount: amount, userID: userID, categoryID: category.cloudID, date: nil) { (success, expense) in
      
      if success, let expense = expense {
        
        Utilities.setDataViewNeedsUpdate()
        self.expenseEntryDelegate?.expenseEntryDismissed()
        
      } else {
        print("failed to create expense")
      }
    }
  }
}

extension ExpenseEntryViewController: UIPickerViewDelegate {
  
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    let category = categoryArray[row]
    return category.name
  }
}

extension ExpenseEntryViewController: UIPickerViewDataSource {
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return categoryArray.count
  }
}

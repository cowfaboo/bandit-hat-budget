//
//  CategoryManagementViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol CategoryManagementDelegate: class {
  func categoryManagementDismissed()
}

class CategoryManagementViewController: UIViewController {

  weak var categoryManagementDelegate: CategoryManagementDelegate?
  
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var monthlyBudgetTextField: UITextField!
  @IBOutlet weak var descriptionTextView: UITextView!
  @IBOutlet weak var createButton: UIButton!
  
  var categoryArray = [BKCategory]()
  
  override func viewDidLoad() {
    super.viewDidLoad()

    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.tableView.reloadData()
    }
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  // MARK: - Action Methods
  
  @IBAction func createButtonTapped() {
    
    guard let name = nameTextField.text, name.characters.count > 0 else {
      print("no name entered")
      return
    }
    
    var monthlyBudget: Float?
    var monthlyBudgetString = monthlyBudgetTextField.text
    if monthlyBudgetString != nil && monthlyBudgetString!.characters.count == 0 {
      monthlyBudgetString = nil
    }
    
    if let monthlyBudgetString = monthlyBudgetString {
      monthlyBudget = Float(monthlyBudgetString)
    }
    
    var description = descriptionTextView.text
    if description != nil && description!.characters.count == 0 {
      description = nil
    }
    
    BKSharedBasicRequestClient.createCategory(withName: name, monthlyBudget: monthlyBudget, description: description) { (success, category) in
      
      if success, let category = category {
        self.categoryArray.append(category)
        self.tableView.reloadData()
        self.nameTextField.text = ""
        self.monthlyBudgetTextField.text = ""
        self.descriptionTextView.text = ""
        Utilities.setDataViewNeedsUpdate()
      } else {
        print("failed to create category")
      }
    }
  }
  
  @IBAction func dismissButtonTapped() {
    categoryManagementDelegate?.categoryManagementDismissed()
  }
}

extension CategoryManagementViewController: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return categoryArray.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
    
    let monthlyBudget = categoryArray[indexPath.row].monthlyBudget
    if monthlyBudget != 0 {
      cell.textLabel?.text = categoryArray[indexPath.row].name + " - $\(monthlyBudget.dollarAmount)"
    } else {
      cell.textLabel?.text = categoryArray[indexPath.row].name
    }
    
    return cell
  }
}

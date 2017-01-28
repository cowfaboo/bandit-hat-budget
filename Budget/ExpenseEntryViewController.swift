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
  
  @IBOutlet weak var tintView: UIView!
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var dollarSignTextField: UITextField!
  
  @IBOutlet weak var addExpenseButton: BHButton!
  @IBOutlet weak var closeButton: UIButton!
  
  @IBOutlet weak var categoryCollectionView: UICollectionView!
  
  @IBOutlet weak var addExpenseButtonContainerViewBottomConstraint: NSLayoutConstraint!
  
  var categoryArray = [BKCategory]()
  
  var selectedCategory: BKCategory? {
    didSet {
      if let selectedCategory = selectedCategory {
        tintView.backgroundColor = selectedCategory.color.withAlphaComponent(0.02)
        nameTextField.tintColor = selectedCategory.color
        amountTextField.tintColor = selectedCategory.color
        closeButton.tintColor = selectedCategory.color
        addExpenseButton.themeColor = selectedCategory.color
      }
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    amountTextField.becomeFirstResponder()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    view.endEditing(true)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    categoryCollectionView.register(UINib(nibName: "CategorySelectionCell", bundle: nil), forCellWithReuseIdentifier: "CategorySelectionCell")
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    
    view.layer.cornerRadius = 8.0
    
    nameTextField.textColor = UIColor.text
    amountTextField.textColor = UIColor.text
    dollarSignTextField.textColor = UIColor.text
    
    nameTextField.tintColor = UIColor.text.withAlphaComponent(0.5)
    amountTextField.tintColor = UIColor.text.withAlphaComponent(0.5)
    
    nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
    
    closeButton.tintColor = UIColor.text
    
    addExpenseButton.isEnabled = false
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.categoryCollectionView.reloadData()
      if (self.categoryArray.count > 0) {
        self.selectedCategory = self.categoryArray[0]
      }
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  // MARK: - Action Methods
  
  @IBAction func dismissButtonTapped() {
    expenseEntryDelegate?.expenseEntryDismissed()
  }
  
  @IBAction func addExpenseButtonTapped() {
    
    let userID = Settings.currentUserID()
    let name = nameTextField.text!
    let amount = Float(amountTextField.text!)!
    
    BKSharedBasicRequestClient.createExpense(withName: name, amount: amount, userID: userID, categoryID: selectedCategory!.cloudID, date: nil) { (success, expense) in
      
      guard success, let _ = expense else {
        print("failed to create expense")
        return
      }
        
      Utilities.setDataViewNeedsUpdate()
      self.expenseEntryDelegate?.expenseEntryDismissed()
    }
  }
  
  
  func keyboardWillHide(_ notification: NSNotification) {
    addExpenseButtonContainerViewBottomConstraint.constant = 0
    view.layoutIfNeeded()
  }
  
  func keyboardWillShow(_ notification: NSNotification) {
    let keyboardSize = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size
    
    if addExpenseButtonContainerViewBottomConstraint.constant == keyboardSize.height {
      return
    }
    
    addExpenseButtonContainerViewBottomConstraint.constant = keyboardSize.height
    view.layoutIfNeeded()
  }
}

// MARK: - Collection View Flow Layout Delegate Methods
extension ExpenseEntryViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
  }
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
    return CGSize(width: Utilities.screenWidth, height: 44)
  }
}

// MARK: - Collection View Data Source Methods
extension ExpenseEntryViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return categoryArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CategorySelectionCell", for: indexPath) as! CategorySelectionCell
    
    cell.category = categoryArray[indexPath.item]
    
    return cell
  }
}

// MARK: - Scroll View Delegate Methods
extension ExpenseEntryViewController: UIScrollViewDelegate {
  
  func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
    
    let targetOffset = targetContentOffset.pointee.x
    let targetIndex = Int(targetOffset / scrollView.bounds.width)
    
    selectedCategory = categoryArray[targetIndex]
  }
}

// MARK: - Text Field Delegate Methods
extension ExpenseEntryViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == amountTextField {
      nameTextField.becomeFirstResponder()
    } else {
      view.endEditing(true)
    }
    
    return true
  }
  
  func nameTextFieldDidChange() {
    updateFormValidity()
  }
  
  func amountTextFieldDidChange() {
    updateFormValidity()
    
    if let amountString = amountTextField.text {
      if amountString.isCompleteDollarAmount() {
        self.nameTextField.becomeFirstResponder()
      }
    }
  }
  
  func updateFormValidity(withNewString newString: String? = nil, inTextField textField: UITextField? = nil) {
    
    let amount = Float(amountTextField.text ?? "")
    let name = nameTextField.text ?? ""
    
    if name.characters.count > 0 && amount != nil && selectedCategory != nil {
      addExpenseButton.isEnabled = true
    } else {
      addExpenseButton.isEnabled = false
    }
  }
}

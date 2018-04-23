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
  func expenseEntered()
  func expenseDeleted()
}

class ExpenseEntryViewController: TopLevelViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  weak var expenseEntryDelegate: ExpenseEntryDelegate?
  
  @IBOutlet weak var tintView: UIView!
  
  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var amountTextField: UITextField!
  @IBOutlet weak var dollarSignTextField: UITextField!
  
  @IBOutlet weak var addExpenseButton: BHButton!
  @IBOutlet weak var deleteExpenseButton: BHButton!
  @IBOutlet weak var changeDateButton: UIButton!
  @IBOutlet weak var dateTextButton: UIButton!
  @IBOutlet weak var closeButton: UIButton!
  
  @IBOutlet weak var categoryCollectionView: UICollectionView!
  
  @IBOutlet weak var addExpenseButtonContainerViewBottomConstraint: NSLayoutConstraint!
  @IBOutlet private weak var deleteButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var deleteButtonLeadingConstraint: NSLayoutConstraint!
  
  var categoryArray = [BKCategory]()
  
  var selectedCategory: BKCategory? {
    didSet {
      if let selectedCategory = selectedCategory {
        tintView.backgroundColor = selectedCategory.color.withAlphaComponent(0.02)
        nameTextField.tintColor = selectedCategory.color
        amountTextField.tintColor = selectedCategory.color
        closeButton.tintColor = selectedCategory.color
        addExpenseButton.themeColor = selectedCategory.color
        changeDateButton.tintColor = selectedCategory.color
        dateTextButton.tintColor = selectedCategory.color
        deleteExpenseButton.themeColor = UIColor.negative
      }
    }
  }
  
  var selectedDate: Date? {
    didSet {
      if selectedDate != nil && selectedDate!.isDateEqualTo(Date()) {
        dateTextButton.alpha = 0.0
      } else {
        dateTextButton.setTitle(selectedDate?.monthDayYearString(), for: .normal)
        UIView.animate(withDuration: 0.2, delay: 0.0, options: [.allowUserInteraction, .curveEaseIn], animations: { 
          self.dateTextButton.alpha = 1.0
        }, completion: nil)
      }
    }
  }
  
  var existingExpense: BKExpense?
  
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
    
    nameTextField.textColor = UIColor.text
    amountTextField.textColor = UIColor.text
    dollarSignTextField.textColor = UIColor.text
    
    nameTextField.tintColor = UIColor.text.withAlphaComponent(0.5)
    amountTextField.tintColor = UIColor.text.withAlphaComponent(0.5)
    
    nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    amountTextField.addTarget(self, action: #selector(amountTextFieldDidChange), for: .editingChanged)
    
    closeButton.tintColor = UIColor.text
    
    addExpenseButton.isEnabled = false
    
    addExpenseButton.isCircular = true
    deleteExpenseButton.isCircular = true
    addExpenseButton.titleLabel?.adjustsFontSizeToFitWidth = true
    deleteExpenseButton.titleLabel?.adjustsFontSizeToFitWidth = true
    addExpenseButton.titleLabel?.minimumScaleFactor = 0.7
    deleteExpenseButton.titleLabel?.minimumScaleFactor = 0.7
    
    if let fetchedCategories = BKCategory.fetchCategories() {
      categoryArray = fetchedCategories
      categoryCollectionView.reloadData()
    }
    
    if let existingExpense = existingExpense {
      nameTextField.text = existingExpense.name
      amountTextField.text = existingExpense.amount.dollarAmount()
      selectedDate = existingExpense.date as Date
      addExpenseButton.setTitle("Update Expense", for: .normal)
      
      deleteButtonWidthConstraint.constant = (view.frame.width - 48) / 3
      deleteButtonLeadingConstraint.constant = 16
      deleteExpenseButton.setTitle("Delete", for: .normal)
      
      if let categoryID = existingExpense.category?.cloudID {
        self.selectedCategory = BKCategory.fetchCategory(withCloudID: categoryID)
        
        if let selectedCategory = self.selectedCategory {
          if let categoryIndex = categoryArray.index(of: selectedCategory) {
            self.categoryCollectionView.selectItem(at: IndexPath(item: categoryIndex, section: 0), animated: false, scrollPosition: .left)
          }
        }
      }
    }
    
    updateCategories()
    
    if !isDismissable {
      closeButton.isHidden = true
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  func updateCategories() {
    
    BKSharedBasicRequestClient.getCategories { (success: Bool, categoryArray: Array<BKCategory>?) in
      
      guard success, let categoryArray = categoryArray else {
        print("failed to get categories")
        return
      }
      
      self.categoryArray = categoryArray
      self.categoryCollectionView.reloadData()
      
      if let existingExpense = self.existingExpense {
        if let categoryID = existingExpense.category?.cloudID {
          self.selectedCategory = BKCategory.fetchCategory(withCloudID: categoryID)
        }
      }
      
      if self.selectedCategory == nil && self.categoryArray.count > 0 {
        self.selectedCategory = self.categoryArray[0]
      }
      
      if let selectedCategory = self.selectedCategory {
        if let categoryIndex = categoryArray.index(of: selectedCategory) {
          self.categoryCollectionView.selectItem(at: IndexPath(item: categoryIndex, section: 0), animated: false, scrollPosition: .left)
        }
      }
      self.updateFormValidity()
    }
  }
  
  // MARK: - Action Methods
  
  @IBAction func dismissButtonTapped() {
    if self.isDismissable {
      topLevelViewControllerDelegate?.topLevelViewControllerDismissed(self)
    }
  }
  
  @IBAction func addExpenseButtonTapped() {
    
    if (!Settings.hasClaimedUser()) {
      print("not signed in. Probably need to do something here.")
      return
    }
    
    let userID = Settings.claimedUserID()!
    let name = nameTextField.text!
    let amount = Float(amountTextField.text!)!
    
    if let existingExpense = existingExpense {
      
      BKSharedBasicRequestClient.updateExpense(expense: existingExpense, name: name, amount: amount, userID: existingExpense.user.cloudID, categoryID: selectedCategory!.cloudID, date: selectedDate) { (success, expense) in
        guard success, let _ = expense else {
          print("failed to update expense")
          return
        }
        
        Utilities.updateDataViews()
        self.expenseEntryDelegate?.expenseEntered()
      }
      
    } else {
      
      BKSharedBasicRequestClient.createExpense(withName: name, amount: amount, userID: userID, categoryID: selectedCategory!.cloudID, date: selectedDate) { (success, expense) in
        
        guard success, let _ = expense else {
          print("failed to create expense")
          return
        }
        
        Utilities.updateDataViews()
        self.expenseEntryDelegate?.expenseEntered()
      }
    }
  }
  
  @IBAction func deleteButtonTapped() {
    
    let cancelAction = BHAlertAction(withTitle: "Cancel") {
      self.dismiss(animated: true, completion: nil)
    }
    
    let deleteAction = BHAlertAction(withTitle: "Delete", color: UIColor.negative) {
      self.deleteExpense() { (success) in
        
        self.dismiss(animated: true, completion: nil)
        
        if success {
          Utilities.updateDataViews()
          self.expenseEntryDelegate?.expenseDeleted()
        }
      }
    }
    
    let alertViewController = BHAlertViewController(withTitle: "Delete Expense?", message: "Are you sure you want to delete this expense?", actions: [cancelAction, deleteAction])
    let topSlideViewController = TopSlideViewController(presenting: alertViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  func deleteExpense(completion: @escaping (Bool) -> ()) {
    
    guard let expense = existingExpense else {
      completion(false)
      return
    }
    
    BKSharedBasicRequestClient.delete(expense: expense) { (success) in
      guard success else {
        print("failed to delete expense")
        completion(false)
        return
      }
      
      completion(true)
    }
  }
  
  @IBAction func changeDateButtonTapped() {
    
    view.endEditing(true)
    
    let calendarViewController = CalendarViewController(nibName: "CalendarViewController", bundle: nil)
    calendarViewController.calendarDelegate = self
    if let themeColor = selectedCategory?.color {
      calendarViewController.themeColor = themeColor
    }
    if let selectedDate = selectedDate {
      calendarViewController.selectedDate = selectedDate
    }
    
    let topSlideViewController = TopSlideViewController(presenting: calendarViewController, from: self)
    present(topSlideViewController, animated: true, completion: nil)
  }
  
  
  @objc func keyboardWillHide(_ notification: NSNotification) {
    addExpenseButtonContainerViewBottomConstraint.constant = 0
    view.layoutIfNeeded()
  }
  
  @objc func keyboardWillShow(_ notification: NSNotification) {
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
  
  @objc func nameTextFieldDidChange() {
    updateFormValidity()
  }
  
  @objc func amountTextFieldDidChange() {
    updateFormValidity()
    
    if let amountString = amountTextField.text {
      if amountString.isCompleteDollarAmount() {
        self.nameTextField.becomeFirstResponder()
      }
    }
  }
  
  func updateFormValidity() {
    
    let amount = Float(amountTextField.text ?? "")
    let name = nameTextField.text ?? ""
    
    if name.count > 0 && amount != nil && selectedCategory != nil {
      addExpenseButton.isEnabled = true
    } else {
      addExpenseButton.isEnabled = false
    }
  }
}

// MARK: - Top Slide Delegate Methods
extension ExpenseEntryViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - Calendar Delegate Methods
extension ExpenseEntryViewController: CalendarDelegate {
  func shouldDismissCalendar(withChosenDate date: Date?) {
    dismiss(animated: true, completion: nil)
    if let date = date {
      if date.isDateEqualTo(Date()) {
        selectedDate = nil
      } else {
        selectedDate = date
      }
    }
    
    if !(amountTextField.text?.isCompleteDollarAmount() ?? false) {
      amountTextField.becomeFirstResponder()
    } else if (nameTextField.text ?? "").count == 0 {
      nameTextField.becomeFirstResponder()
    }
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension ExpenseEntryViewController: UIViewControllerTransitioningDelegate {
  
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

//
//  CategoryDetailViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-04-05.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol CategoryDetailDelegate: class {
  func shouldDismissCategoryDetailView()
  func didCreateNewCategory()
  func didUpdateCategory()
  func didDeleteCategory()
}

enum CategoryDetailMode {
  case create
  case view
  case edit
}

class CategoryDetailViewController: UIViewController, InteractivePresenter {
  
  var presentationAnimator: PresentationAnimator = TopSlideAnimator()
  
  weak var delegate: CategoryDetailDelegate?
  
  fileprivate var currentTextInput: UITextInput?
  
  @IBOutlet weak var tintView: UIView!
  
  @IBOutlet private weak var closeButton: UIButton!
  @IBOutlet private weak var titleLabel: UILabel!
  @IBOutlet fileprivate weak var nameTextField: UITextField!
  @IBOutlet private weak var budgetPrefixTextField: UITextField!
  @IBOutlet fileprivate weak var budgetTextField: UITextField!
  @IBOutlet fileprivate weak var descriptionPlaceholderLabel: UILabel!
  @IBOutlet fileprivate weak var descriptionTextView: UITextView!
  @IBOutlet private weak var colorStackView: UIStackView!
  @IBOutlet private weak var actionButton: BHButton!
  @IBOutlet private weak var deleteButton: BHButton!
  
  @IBOutlet private weak var nameTextFieldHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var nameTextFieldTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var nameUnderlineViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var descriptionTextViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var colorStackViewHeightConstraint: NSLayoutConstraint!
  @IBOutlet private weak var colorStackViewTopConstraint: NSLayoutConstraint!
  @IBOutlet private weak var deleteButtonWidthConstraint: NSLayoutConstraint!
  @IBOutlet private weak var deleteButtonLeadingConstraint: NSLayoutConstraint!
  
  @IBOutlet private var colorButtonArray: [UIButton]!
  private var colorButtonCheckMarkArray = [UIImageView]()
  private var selectedColorButton: UIButton?
  
  private var categoryDetailMode = CategoryDetailMode.create {
    didSet {
      if categoryDetailMode == .create {
        transitionToCreateMode()
      } else if categoryDetailMode == .view {
        transitionToViewMode()
      } else {
        transitionToEditMode()
      }
    }
  }
  
  var category: BKCategory?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidShow(_:)), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
    NotificationCenter.default.addObserver(self, selector: #selector(keyboardDidHide(_:)), name: NSNotification.Name.UIKeyboardDidHide, object: nil)
    
    nameTextField.addTarget(self, action: #selector(nameTextFieldDidChange), for: .editingChanged)
    budgetTextField.addTarget(self, action: #selector(budgetTextFieldDidChange), for: .editingChanged)
    
    closeButton.tintColor = UIColor.text
    titleLabel.tintColor = UIColor.text
    actionButton.themeColor = UIColor.text
    deleteButton.themeColor = UIColor.negative.withAlphaComponent(0.75)
    nameTextField.textColor = UIColor.text
    nameTextField.tintColor = UIColor.text
    budgetTextField.textColor = UIColor.text
    budgetTextField.tintColor = UIColor.text
    budgetPrefixTextField.textColor = UIColor.text
    descriptionTextView.textColor = UIColor.text
    descriptionTextView.tintColor = UIColor.text
    descriptionTextView.textContainerInset = UIEdgeInsetsMake(11.0, 0.0, 0.0, 0.0)
    descriptionTextView.textContainer.lineFragmentPadding = 0
    
    var index = 0
    for button in colorButtonArray {
      button.layer.cornerRadius = 15.0
      button.backgroundColor = UIColor.palette[index]
      let imageView = UIImageView(image: UIImage(named: "checkmarkButton"))
      imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
      imageView.transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
      button.addSubview(imageView)
      colorButtonCheckMarkArray.append(imageView)
      index += 1
    }
    
    if category == nil {
      categoryDetailMode = .create
    } else {
      categoryDetailMode = .view
    }
  }
  
  deinit {
    NotificationCenter.default.removeObserver(self)
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func transitionToCreateMode() {
    actionButton.setTitle("Create", for: .normal)
    titleLabel.text = "New Category"
    nameTextField.isEnabled = true
    budgetTextField.isEnabled = true
    budgetPrefixTextField.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)
    budgetPrefixTextField.text = "$"
    descriptionTextView.isEditable = true
    descriptionTextView.isSelectable = true
    descriptionPlaceholderLabel.alpha = 1
    
    nameTextFieldHeightConstraint.constant = 44
    nameTextFieldTopConstraint.constant = 16
    nameUnderlineViewHeightConstraint.constant = 1
    descriptionTextViewHeightConstraint.constant = 72
    descriptionTextViewTopConstraint.constant = 16
    colorStackViewHeightConstraint.constant = 68
    colorStackViewTopConstraint.constant = 16
    
    nameTextField.isHidden = false
    descriptionTextView.isHidden = false
    colorStackView.isHidden = false
    
    updateFormValidity()
    
    colorButtonTapped(sender: colorButtonArray[Int(arc4random_uniform(UInt32(colorButtonArray.count)))])
    
    deleteButtonWidthConstraint.constant = 0
    deleteButtonLeadingConstraint.constant = 0
    
    if let viewContainer = self.parent as? ViewContainer {
      viewContainer.contentHeightDidChange(448)
    }
    
    view.layoutIfNeeded()
  }
  
  func transitionToViewMode() {
    actionButton.setTitle("Edit", for: .normal)
    titleLabel.text = category?.name
    nameTextField.isEnabled = false
    budgetTextField.text = "/ month"
    budgetTextField.isEnabled = false
    budgetPrefixTextField.font = UIFont.systemFont(ofSize: 20.0, weight: UIFontWeightMedium)
    budgetPrefixTextField.text = category?.monthlyBudget.simpleDollarAmount()
    descriptionTextView.text = category?.details
    descriptionTextView.isEditable = false
    descriptionTextView.isSelectable = false
    descriptionPlaceholderLabel.alpha = 0
    
    nameTextFieldHeightConstraint.constant = 0
    nameTextFieldTopConstraint.constant = 0
    nameTextField.isHidden = true
    nameUnderlineViewHeightConstraint.constant = 0
    let heightModifier: CGFloat
    if let details = category?.details, details.characters.count > 0 {
      descriptionTextViewHeightConstraint.constant = 72
      descriptionTextViewTopConstraint.constant = 16
      heightModifier = 0
    } else {
      descriptionTextViewHeightConstraint.constant = 0
      descriptionTextViewTopConstraint.constant = 0
      descriptionTextView.isHidden = true
      heightModifier = 88
    }
    
    colorStackViewHeightConstraint.constant = 0
    colorStackViewTopConstraint.constant = 0
    colorStackView.isHidden = true
    
    actionButton.isEnabled = true
    
    deleteButtonWidthConstraint.constant = (view.frame.width - 32 - 12) / 3
    deleteButtonLeadingConstraint.constant = 12
    
    if let colorIndex = UIColor.paletteIndex(of: category!.color) {
      setColor(forIndex: colorIndex)
    } else {
      setColor(color: category!.color)
    }
    
    if let viewContainer = self.parent as? ViewContainer {
      viewContainer.contentHeightDidChange(303 - heightModifier)
    } 
  }
  
  func transitionToEditMode() {
    actionButton.setTitle("Save", for: .normal)
    nameTextField.isEnabled = true
    nameTextField.text = category?.name
    budgetTextField.isEnabled = true
    budgetTextField.text = category?.monthlyBudget.simpleDollarAmount(withDollarSign: false)
    budgetTextField.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)
    budgetPrefixTextField.font = UIFont.systemFont(ofSize: 18.0, weight: UIFontWeightRegular)
    budgetPrefixTextField.text = "$"
    descriptionTextView.isEditable = true
    descriptionTextView.isSelectable = true
    descriptionPlaceholderLabel.alpha = 1
    
    nameTextFieldHeightConstraint.constant = 44
    nameTextFieldTopConstraint.constant = 16
    nameUnderlineViewHeightConstraint.constant = 1
    descriptionTextViewHeightConstraint.constant = 72
    descriptionTextViewTopConstraint.constant = 16
    colorStackViewHeightConstraint.constant = 68
    colorStackViewTopConstraint.constant = 16
    
    nameTextField.isHidden = false
    descriptionTextView.isHidden = false
    colorStackView.isHidden = false
    
    updateFormValidity()
    
    if let viewContainer = self.parent as? ViewContainer {
      viewContainer.contentHeightDidChange(448)
    }
    
    if let colorIndex = UIColor.paletteIndex(of: category!.color) {
      colorButtonTapped(sender: colorButtonArray[colorIndex])
    } else {
      setColor(color: category!.color)
    }
    
    textViewDidChange(descriptionTextView)
    
    deleteButtonWidthConstraint.constant = 0
    deleteButtonLeadingConstraint.constant = 0
    
    UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseOut, .allowUserInteraction], animations: {
      self.titleLabel.alpha = 0.0
      self.view.layoutIfNeeded()
    }) { (success) in
      self.titleLabel.text = "Edit Category"
      UIView.animate(withDuration: 0.1, delay: 0.0, options: [.curveEaseIn, .allowUserInteraction], animations: {
        self.titleLabel.alpha = 1.0
      }, completion: nil)
    }
  }
  
  
  @IBAction func closeButtonTapped() {
    delegate?.shouldDismissCategoryDetailView()
  }
  
  @IBAction func colorButtonTapped(sender: UIButton) {
    
    guard let index = colorButtonArray.index(of: sender) else {
      return
    }
    
    guard sender != selectedColorButton else {
      return
    }
    
    let previousSelectedColorButton = selectedColorButton
    selectedColorButton = sender
    
    setColor(forIndex: index)
    UIView.animate(withDuration: 0.5, delay: 0.0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
      sender.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
      self.colorButtonCheckMarkArray[index].transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
      previousSelectedColorButton?.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
      if previousSelectedColorButton != nil {
        if let previousIndex = self.colorButtonArray.index(of: previousSelectedColorButton!) {
          self.colorButtonCheckMarkArray[previousIndex].transform = CGAffineTransform(scaleX: 0.01, y: 0.01)
        }
      }
    }, completion: nil)
    
    
  }
  
  func setColor(forIndex index: Int) {
    
    guard index < UIColor.palette.count else {
      return
    }
    
    let color = UIColor.palette[index]
    titleLabel.textColor = color
    tintView.backgroundColor = color.withAlphaComponent(0.02)
    closeButton.tintColor = color
    actionButton.themeColor = color
    nameTextField.tintColor = color
    budgetTextField.tintColor = color
    descriptionTextView.tintColor = color
  }
  
  func setColor(color: UIColor) {
    titleLabel.textColor = color
    tintView.backgroundColor = color.withAlphaComponent(0.02)
    closeButton.tintColor = color
    actionButton.themeColor = color
    nameTextField.tintColor = color
    budgetTextField.tintColor = color
    descriptionTextView.tintColor = color
  }
  
  @IBAction func actionButtonTapped() {
    if categoryDetailMode == .create {
      createCategory()
    } else if categoryDetailMode == .edit {
      updateCategory()
    } else if categoryDetailMode == .view {
      categoryDetailMode = .edit
    }
  }
  
  @IBAction func deleteButtonTapped() {
    
    guard let category = category else {
      return
    }
    
    let cancelAction = BHAlertAction(withTitle: "Cancel") {
      self.dismiss(animated: true, completion: nil)
    }
    
    let deleteAction = BHAlertAction(withTitle: "Delete", color: UIColor.negative) {
      self.deleteCategory() { (success) in
        
        self.dismiss(animated: true, completion: nil)
        
        if success {
          self.delegate?.didDeleteCategory()
          Utilities.setDataViewNeedsUpdate()
        }
      }
    }
    
    let alertViewController = BHAlertViewController(withTitle: "Delete Category?", message: "Are you sure you want to delete \"\(category.name)\"? Any expenses belonging to this category will become uncategorized, and access will be limited.", actions: [cancelAction, deleteAction])
    let topSlideViewController = TopSlideViewController(presenting: alertViewController, from: self, withDistanceFromTop: 64.0)
    present(topSlideViewController, animated: true, completion: nil)
    
  }
  
  func createCategory() {
    let name = nameTextField.text!
    let budget = Float(budgetTextField.text!)!
    let color = selectedColorButton!.backgroundColor!
    
    var description = descriptionTextView.text
    if description != nil && description!.characters.count == 0 {
      description = nil
    }
    
    BKSharedBasicRequestClient.createCategory(withName: name, color: color, monthlyBudget: budget, description: description) { (success, category) in
      
      guard success, let category = category else {
        print("failed to update category")
        return
      }
      
      self.view.endEditing(true)
      self.delegate?.didCreateNewCategory()
      Utilities.setDataViewNeedsUpdate()
    }
  }
  
  func updateCategory() {
    guard let category = category else {
      return
    }
    
    let name = nameTextField.text!
    let budget = Float(budgetTextField.text!)!
    let color = selectedColorButton!.backgroundColor!
    
    var description = descriptionTextView.text
    if description != nil && description!.characters.count == 0 {
      description = nil
    }
    
    
    
    BKSharedBasicRequestClient.update(category: category, name: name, color: color, monthlyBudget: budget, description: description) { (success, category) in
      guard success, let category = category else {
        print("failed to create category")
        return
      }
      
      self.view.endEditing(true)
      self.delegate?.didUpdateCategory()
      Utilities.setDataViewNeedsUpdate()
    }
  }
  
  func deleteCategory(completion: @escaping (Bool) -> ()) {
   
    guard let category = category else {
      completion(false)
      return
    }
    
    BKSharedBasicRequestClient.delete(category: category) { (success) in
      guard success else {
        print("failed to delete category")
        completion(false)
        return
      }
      
      completion(true)
    }
    
  }
  
  func nameTextFieldDidChange() {
    updateFormValidity()
  }
  
  func budgetTextFieldDidChange() {
    updateFormValidity()
    
    if let budgetString = budgetTextField.text {
      if budgetString.isCompleteDollarAmount() {
        self.descriptionTextView.becomeFirstResponder()
      }
    }
  }
  
  func updateFormValidity() {
    
    let budget = Float(budgetTextField.text ?? "")
    let name = nameTextField.text ?? ""
    
    if name.characters.count > 0 && budget != nil {
      actionButton.isEnabled = true
    } else {
      actionButton.isEnabled = false
    }
  }
  
  func keyboardDidHide(_ notification: NSNotification) {
    print("keyboard did hide")
    if let topSlideViewController = parent as? TopSlideViewController {
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop
      
      UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
        topSlideViewController.view.layoutIfNeeded()
      }, completion: nil)
    }
  }
  
  func keyboardDidShow(_ notification: NSNotification) {
    
    guard let currentTextInput = currentTextInput as? UIView, let topSlideViewController = parent as? TopSlideViewController else {
      return
    }
    
    let currentKeyboardHeight = (notification.userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue.size.height
    let availableSpace = Utilities.screenHeight - currentKeyboardHeight
    let inputPositionInContainer = currentTextInput.frame.origin.y
    let idealInputPositionOnScreen = inputPositionInContainer + topSlideViewController.originalDistanceFromTop
    let lowestIdealPosition = (availableSpace / 2) - (currentTextInput.frame.size.height)
    let containerHeight = topSlideViewController.containerView.frame.size.height
    
    func idealTextInputIsInTopCenterRange() -> Bool {
      return idealInputPositionOnScreen < lowestIdealPosition && idealInputPositionOnScreen > 16
    }
    
    func textInputFitsWhenBottomVisible() -> Bool {
      let containerTop = availableSpace - 16 - containerHeight
      let inputPositionOnScreen = inputPositionInContainer + containerTop
      
      return inputPositionOnScreen > 16
    }
    
    func containerViewCanBeCentered() -> Bool {
      return containerHeight < availableSpace - 32
    }
    
    // try to center whole view;
    // then, try to get whole view 16 px from keyboard;
    // then, move to ideal position if its acceptable spot for text input;
    // then, center text input in top half of available space
    
    if containerViewCanBeCentered() {
      topSlideViewController.containerViewTopConstraint.constant = (availableSpace - containerHeight) / 2
    } else if textInputFitsWhenBottomVisible() {
      topSlideViewController.containerViewTopConstraint.constant = availableSpace - 16 - containerHeight
    } else if idealTextInputIsInTopCenterRange() {
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop
    } else {
      let distanceToTravel = idealInputPositionOnScreen - ((availableSpace / 4) - (currentTextInput.frame.size.height / 2))
      topSlideViewController.containerViewTopConstraint.constant = topSlideViewController.originalDistanceFromTop - distanceToTravel
    }
    
    
    UIView.animate(withDuration: 0.4, delay: 0.0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0.0, options: .allowUserInteraction, animations: {
      topSlideViewController.view.layoutIfNeeded()
    }, completion: nil)
  }
}

extension CategoryDetailViewController: UITextViewDelegate {
  
  func textViewDidBeginEditing(_ textView: UITextView) {
    currentTextInput = textView
  }
  
  func textViewDidChange(_ textView: UITextView) {
    if textView.text.isEmpty {
      descriptionPlaceholderLabel.isHidden = false
    } else {
      descriptionPlaceholderLabel.isHidden = true
    }
  }
  
  func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
    if text == "\n" {
      textView.resignFirstResponder()
      return false
    }
    return true
  }
}

extension CategoryDetailViewController: UITextFieldDelegate {
  
  func textFieldShouldReturn(_ textField: UITextField) -> Bool {
    
    if textField == nameTextField {
      budgetTextField.becomeFirstResponder()
    } else {
      descriptionTextView.becomeFirstResponder()
    }
    
    return true
  }
  
  func textFieldDidBeginEditing(_ textField: UITextField) {
    currentTextInput = textField
  }
}

// MARK: - Top Slide Delegate Methods
extension CategoryDetailViewController: TopSlideDelegate {
  func shouldDismissTopSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

// MARK: - View Controller Transitioning Delegate Methods
extension CategoryDetailViewController: UIViewControllerTransitioningDelegate {
  
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

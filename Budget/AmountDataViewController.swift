//
//  AmountDataViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

protocol AmountDataDelegate: class {
  func didFinishLoadingAmountData()
}

class AmountDataViewController: UIViewController {
  
  weak var amountDataDelegate: AmountDataDelegate?
  
  @IBOutlet weak var collectionView: UICollectionView!
  @IBOutlet weak var headerView: UIView!
  
  var amountArray = [BKAmount]()
  var date: Date = Date()
  var timeRangeType: TimeRangeType = .monthly
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    let dataHeaderViewController = DataHeaderViewController(nibName: "DataHeaderViewController", bundle: nil)
    dataHeaderViewController.date = date
    dataHeaderViewController.timeRangeType = timeRangeType
    add(dataHeaderViewController, to: headerView)
    
    collectionView.register(UINib(nibName: "AmountDataCell", bundle: nil), forCellWithReuseIdentifier: "AmountDataCell")
    
    fetchAmounts()
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    
    if Utilities.dataViewNeedsUpdate() {
      fetchAmounts()
    } else {
      collectionView.reloadData()
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  func fetchAmounts() {
    
    var dates: (startDate: Date, endDate: Date)
    if timeRangeType == .monthly {
      dates = date.startAndEndOfMonth()
    } else {
      dates = date.startAndEndOfYear()
    }
    
    BKSharedBasicRequestClient.getAmountsByCategory(forUserID: Settings.currentUserID(), startDate: dates.startDate, endDate: dates.endDate) { (success, amountArray) in
      
      guard success, let amountArray = amountArray else {
        print("failed to get amounts")
        return
      }
      
      self.amountArray = amountArray
      self.collectionView.reloadData()
      self.amountDataDelegate?.didFinishLoadingAmountData()
    }
  }
}

// MARK: - Collection View Flow Layout Delegate Methods
extension AmountDataViewController: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
    
    let inset = (collectionView.frame.size.width - (136 * 2.0)) / 3.0
    return UIEdgeInsetsMake(0, inset, 0, inset)
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    
    let expenseDataViewController = ExpenseDataViewController(nibName: "ExpenseDataViewController", bundle: nil)
    expenseDataViewController.date = date
    expenseDataViewController.timeRangeType = timeRangeType
    expenseDataViewController.shouldIncludeDataHeader = false
    
    if let categoryID = amountArray[indexPath.item].categoryID {
      if let category = BKCategory.fetchCategory(withCloudID: categoryID) {
        expenseDataViewController.category = category
      }
    }
    
    let bottomSlideViewController = BottomSlideViewController(nibName: "BottomSlideViewController", bundle: nil)
    bottomSlideViewController.viewController = expenseDataViewController
    bottomSlideViewController.modalPresentationStyle = .overFullScreen
    bottomSlideViewController.bottomSlideDelegate = self
    expenseDataViewController.expenseDataDelegate = bottomSlideViewController
    
    present(bottomSlideViewController, animated: true, completion: nil)
  }
}

// MARK: - Collection View Data Source Methods
extension AmountDataViewController: UICollectionViewDataSource {
  
  func numberOfSections(in collectionView: UICollectionView) -> Int {
    return 1
  }
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    return amountArray.count
  }
  
  func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "AmountDataCell", for: indexPath) as! AmountDataCell
    
    let completionPercentage: Float
    if (timeRangeType == .monthly && date.isMonthEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfMonth()
    } else if (timeRangeType == .annual && date.isYearEqualTo(Date())) {
      completionPercentage = Date().completionPercentageOfYear()
    } else {
      completionPercentage = 0
    }
    
    cell.initialize(withAmount: amountArray[indexPath.item], timeRangeType: timeRangeType, completionPercentage: completionPercentage)
    
    return cell
  }
}

// MARK: - Bottom Slide Delegate Methods
extension AmountDataViewController: BottomSlideDelegate {
  
  func shouldDismissBottomSlideViewController() {
    dismiss(animated: true, completion: nil)
  }
}

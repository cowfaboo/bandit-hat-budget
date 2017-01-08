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
    
    cell.amount = amountArray[indexPath.item]
    cell.timeRangeType = timeRangeType
    if (timeRangeType == .monthly && Utilities.isMonthOf(firstDate: date, equalToMonthOf: Date())) {
      cell.completionPercentage = Utilities.getCompletionPercentageOfMonth(from: Date())
    } else if (timeRangeType == .annual && Utilities.isYearOf(firstDate: date, equalToMonthOf: Date())) {
      cell.completionPercentage = Utilities.getCompletionPercentageOfYear(from: Date())
    }
    
    return cell
  }
}

// MARK: - Expense List Delegate Methods
extension AmountDataViewController: ExpenseDataDelegate {
  
  func shouldDismissExpenseData() {
    dismiss(animated: true, completion: nil)
  }
  
  func didFinishLoadingExpenseData() {
    
  }
}

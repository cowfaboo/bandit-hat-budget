//
//  BKAmount.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-30.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

public class BKAmount {
  
  public var amount: Float
  public var categoryID: Int64?
  public var userID: Int64?
  public var startDate: Date?
  public var endDate: Date?
  
  init?(amountDictionary: Dictionary<String, AnyObject>) {
    
    guard let amountString = amountDictionary["amount"] as? String, let amount = Float(amountString) else {
      return nil
    }
    
    self.amount = amount
    
    if let categoryID = amountDictionary["category_id"] as? Int64 {
      self.categoryID = categoryID
    }
    
    if let userID = amountDictionary["user_id"] as? Int64 {
      self.userID = userID
    }
    
    if let startDateString = amountDictionary["start_date"] as? String {
      if let startDate = BKUtilities.date(from: startDateString) {
        self.startDate = startDate
      }
    }
    
    if let endDateString = amountDictionary["end_date"] as? String {
      if let endDate = BKUtilities.date(from: endDateString) {
        self.endDate = endDate
      }
    }
  }
}

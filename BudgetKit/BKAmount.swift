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
  public var categoryID: String?
  public var userID: String?
  public var startDate: Date?
  public var endDate: Date?
  
  init(withAmount amount: Float, categoryID: String?, userID: String?, startDate: Date?, endDate: Date?) {
    self.amount = amount
    self.categoryID = categoryID
    self.userID = userID
    self.startDate = startDate
    self.endDate = endDate
  }
  
  init?(amountDictionary: Dictionary<String, AnyObject>) {
    
    guard let amountNumber = amountDictionary["amount"] as? NSNumber else {
      return nil
    }
    
    self.amount = Float(truncating: amountNumber)
    
    if let categoryID = amountDictionary["category_id"] as? String {
      self.categoryID = categoryID
    }
    
    if let userID = amountDictionary["user_id"] as? String {
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

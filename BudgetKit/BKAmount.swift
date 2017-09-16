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
  
  init?(amountDictionary: Dictionary<String, AnyObject>) {
    
    guard let amountString = amountDictionary["amount"] as? String, let amount = Float(amountString) else {
      return nil
    }
    
    self.amount = amount
    
    if let categoryID = amountDictionary["category"] as? String {
      self.categoryID = categoryID
    }
    
    if let userID = amountDictionary["user"] as? String {
      self.userID = userID
    }
    
    if let startDateString = amountDictionary["startDate"] as? String {
      if let startDate = BKUtilities.date(from: startDateString) {
        self.startDate = startDate
      }
    }
    
    if let endDateString = amountDictionary["endDate"] as? String {
      if let endDate = BKUtilities.date(from: endDateString) {
        self.endDate = endDate
      }
    }
  }
}

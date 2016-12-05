//
//  BKExpense.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-30.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

public class BKExpense {
  
  var cloudID: Int64
  public var name: String
  public var amount: Float
  public var userID: Int64
  public var categoryID: Int64?
  public var date: Date
  var dateCreated: Date
  var dateUpdated: Date
  
  init?(expenseDictionary: Dictionary<String, AnyObject>) {
    
    guard let cloudID = expenseDictionary["id"] as? Int64,
      let name = expenseDictionary["name"] as? String,
      let amountString = expenseDictionary["amount"] as? String, let amount = Float(amountString),
      let userID = expenseDictionary["user_id"] as? Int64,
      let dateString = expenseDictionary["date"] as? String,
      let dateCreatedString = expenseDictionary["created_at"] as? String,
      let dateUpdatedString = expenseDictionary["updated_at"] as? String else {
        return nil
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString),
      let date = BKUtilities.date(from: dateString) else {
        return nil
    }
    
    self.cloudID = cloudID
    self.name = name
    self.amount = amount
    self.userID = userID
    self.date = date
    self.dateCreated = dateCreated
    self.dateUpdated = dateUpdated
    
    if let categoryID = expenseDictionary["category_id"] as? Int64 {
      self.categoryID = categoryID
    }
  }
}

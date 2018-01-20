//
//  BKExpense.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-30.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

public class BKExpense {
  
  var cloudID: String
  public var name: String
  public var amount: Float
  public var userID: String
  public var categoryID: String?
  public var date: Date
  var dateCreated: Date
  var dateUpdated: Date
  
  init?(expenseDictionary: Dictionary<String, AnyObject>) {
    
    guard let cloudID = expenseDictionary["_id"] as? String,
      let name = expenseDictionary["name"] as? String,
      let amountNumber = expenseDictionary["amount"] as? NSNumber,
      let userID = expenseDictionary["user"] as? String,
      let dateString = expenseDictionary["date"] as? String,
      let dateCreatedString = expenseDictionary["createdAt"] as? String,
      let dateUpdatedString = expenseDictionary["updatedAt"] as? String else {
        return nil
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString),
      let date = BKUtilities.date(from: dateString) else {
        return nil
    }
    
    self.cloudID = cloudID
    self.name = name
    self.amount = Float(truncating: amountNumber)
    self.userID = userID
    self.date = date
    self.dateCreated = dateCreated
    self.dateUpdated = dateUpdated
    
    if let categoryID = expenseDictionary["category"] as? String {
      self.categoryID = categoryID
    }
  }
}

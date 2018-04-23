//
//  BKAmount.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-30.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation
import CoreData

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

  public class func getAmount(forUser user: BKUser? = nil, startDate: Date? = nil, endDate: Date? = nil, completion: @escaping (BKAmount?) -> ()) {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BKExpense.fetchRequest()
    
    var predicateArray = [NSPredicate]()
    if let user = user {
      predicateArray.append(NSPredicate(format: "user == %@", user))
    }
    
    if let startDate = startDate {
      predicateArray.append(NSPredicate(format: "date >= %@", startDate as NSDate))
    }
    
    if let endDate = endDate {
      predicateArray.append(NSPredicate(format: "date <= %@", endDate as NSDate))
    }
    
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
    fetchRequest.resultType = .dictionaryResultType
    
    let amountExpression = NSExpression(forKeyPath: "amount")
    let sumExpression = NSExpression(forFunction: "sum:", arguments: [amountExpression])
    
    let sumExpressionDescription = NSExpressionDescription()
    sumExpressionDescription.name = "amountSum"
    sumExpressionDescription.expression = sumExpression
    sumExpressionDescription.expressionResultType = .floatAttributeType
    
    fetchRequest.propertiesToFetch = [sumExpressionDescription]
    
    let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchronousResult) in
      processAmountFetchResult(asynchronousResult, withUser: user, startDate: startDate, endDate: endDate, andCompletionHandler: completion)
    }
    
    guard let result = try? viewContext.execute(asynchronousFetchRequest) else {
      print("asynchronous BKAmount fetch request failed")
      return
    }
    
  }
  
  public class func getAmountsByCategory(forUser user: BKUser? = nil, startDate: Date? = nil, endDate: Date? = nil, completion: @escaping ([BKAmount]) -> ()) {
    
    guard let categories = BKCategory.fetchCategories() else {
      completion([])
      return
    }
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    
    let fetchRequest: NSFetchRequest<NSFetchRequestResult> = BKExpense.fetchRequest()
    
    var predicateArray = [NSPredicate]()
    if let user = user {
      predicateArray.append(NSPredicate(format: "user == %@", user))
    }
    
    if let startDate = startDate {
      predicateArray.append(NSPredicate(format: "date >= %@", startDate as NSDate))
    }
    
    if let endDate = endDate {
      predicateArray.append(NSPredicate(format: "date <= %@", endDate as NSDate))
    }
    
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
    fetchRequest.resultType = .dictionaryResultType
    
    let amountExpression = NSExpression(forKeyPath: "amount")
    let sumExpression = NSExpression(forFunction: "sum:", arguments: [amountExpression])
    let categoryExpression = NSExpression(forKeyPath: "category.cloudID")
    
    let sumExpressionDescription = NSExpressionDescription()
    sumExpressionDescription.name = "amountSum"
    sumExpressionDescription.expression = sumExpression
    sumExpressionDescription.expressionResultType = .floatAttributeType
    
    let categoryExpressionDescription = NSExpressionDescription()
    categoryExpressionDescription.name = "categoryID"
    categoryExpressionDescription.expression = categoryExpression
    categoryExpressionDescription.expressionResultType = .stringAttributeType
    
    fetchRequest.propertiesToGroupBy = [categoryExpressionDescription]
    fetchRequest.propertiesToFetch = [sumExpressionDescription, categoryExpressionDescription]
    
    let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (asynchronousResult) in
      processAmountsByCategoryFetchResult(asynchronousResult, withCategories: categories, user: user, startDate: startDate, endDate: endDate, andCompletionHandler: completion)
    }
    
    guard let result = try? viewContext.execute(asynchronousFetchRequest) else {
      print("asynchronous BKAmount fetch request failed")
      return
    }
  }
  
  class func processAmountFetchResult(_ asynchronousResult: NSAsynchronousFetchResult<NSFetchRequestResult>, withUser user: BKUser?, startDate: Date?, endDate: Date?, andCompletionHandler completion: @escaping (BKAmount?) -> ()) {
    
    guard let results = asynchronousResult.finalResult as? Array<Dictionary<String, Any>>, results.count > 0 else {
      completion(nil)
      return
    }
    
    var amount = BKAmount(withAmount: Float(truncating: results[0]["amountSum"] as! NSNumber), categoryID: nil, userID: user?.cloudID, startDate: startDate, endDate: endDate)
    
    DispatchQueue.main.async {
      completion(amount)
    }
  }
  
  class func processAmountsByCategoryFetchResult(_ asynchronousResult: NSAsynchronousFetchResult<NSFetchRequestResult>, withCategories categories: [BKCategory], user: BKUser?, startDate: Date?, endDate: Date?, andCompletionHandler completion: @escaping ([BKAmount]) -> ()) {
    
    guard let results = asynchronousResult.finalResult as? Array<Dictionary<String, Any>> else {
      completion([])
      return
    }
    
    var amountArray = [BKAmount]()
    
    for resultsDictionary in results {
      let amount = BKAmount(withAmount: Float(truncating: resultsDictionary["amountSum"] as! NSNumber), categoryID: (resultsDictionary["categoryID"] as! String), userID: user?.cloudID, startDate: startDate, endDate: endDate)
      amountArray.append(amount)
    }
    
    
    // now iterate through categories to check if results are missing any. If so, add them with amount 0
    for category in categories {
      if !results.contains(where: { ($0["categoryID"] as! String) == category.cloudID}) {
        let emptyAmount = BKAmount(withAmount: 0, categoryID: category.cloudID, userID: user?.cloudID, startDate: startDate, endDate: endDate)
        amountArray.append(emptyAmount)
      }
    }
    
    // finally, sort amount array so that amounts are always displayed in a consistent order
    amountArray.sort {
      if $0.categoryID == nil {
        return false
      } else if $1.categoryID == nil {
        return true
      } else {
        return $0.categoryID! < $1.categoryID!
      }
    }
    
    
    DispatchQueue.main.async {
      completion(amountArray)
    }
  }
}

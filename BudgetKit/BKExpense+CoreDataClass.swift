//
//  BKExpense+CoreDataClass.swift
//  BudgetKit
//
//  Created by Daniel Gauthier on 2018-01-24.
//  Copyright © 2018 Bandit Hat Apps. All rights reserved.
//
//

import Foundation
import CoreData

@objc(BKExpense)
public class BKExpense: NSManagedObject {

  public class func createOrUpdate(with expenseDictionary: Dictionary<String, AnyObject>) -> BKExpense? {
    
    guard let cloudID = expenseDictionary["_id"] as? String else {
      return nil
    }
    
    if let expense = fetchExpense(withCloudID: cloudID) {
      let _ = expense.configure(with: expenseDictionary)
      return expense
    }
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    
    let expense = NSEntityDescription.insertNewObject(forEntityName: "BKExpense", into: viewContext) as! BKExpense
    if expense.configure(with: expenseDictionary) {
      return expense
    } else {
      return nil
    }
  }
  
  public class func fetchExpense(withCloudID cloudID: String) -> BKExpense? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKExpense> = self.fetchRequest()
    
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        let expense = results.first!
        return expense
      }
    }
    
    return nil
  }
  
  public class func fetchExpenses(forUser user: BKUser? = nil, category: BKCategory? = nil, startDate: Date? = nil, endDate: Date? = nil) -> [BKExpense] {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKExpense> = self.fetchRequest()
    
    var predicateArray = [NSPredicate]()
    if let user = user {
      predicateArray.append(NSPredicate(format: "user == %@", user))
    }
    
    if let category = category {
      predicateArray.append(NSPredicate(format: "category == %@", category))
    }
    
    if let startDate = startDate {
      predicateArray.append(NSPredicate(format: "date >= %@", startDate as NSDate))
    }
    
    if let endDate = endDate {
      predicateArray.append(NSPredicate(format: "date <= %@", endDate as NSDate))
    }
    
    fetchRequest.predicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicateArray)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      return results
    }
    
    return []
  }
  
  public class func deleteExpense(withCloudID cloudID: String) {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKExpense> = self.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    var expense: BKExpense?
    
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        expense = results.first
      }
    }
    
    guard expense != nil else {
      return
    }
    
    do {
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
      try BKSharedDataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: BKSharedDataController.persistentContainer.viewContext)
      BKSharedDataController.saveContext()
      
    } catch {
      print("failed to properly delete expense locally")
    }
  }
  
  func configure(with expenseDictionary: Dictionary<String, AnyObject>) -> Bool {
    
    guard let cloudID = expenseDictionary["_id"] as? String,
      let name = expenseDictionary["name"] as? String,
      let dateString = expenseDictionary["date"] as? String,
      let dateCreatedString = expenseDictionary["createdAt"] as? String,
      let dateUpdatedString = expenseDictionary["updatedAt"] as? String,
      let userID = expenseDictionary["user"] as? String else {
        return false
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString),
      let date = BKUtilities.date(from: dateString) else {
        return false
    }
    
    guard let user = BKUser.fetchUser(withCloudID: userID) else {
      return false
    }
    
    self.cloudID = cloudID
    self.name = name
    self.dateCreated = dateCreated as NSDate
    self.dateUpdated = dateUpdated as NSDate
    self.date = date as NSDate
    self.user = user
    
    if let amount = expenseDictionary["amount"] as? NSNumber {
      self.amount = Float(truncating: amount)
    }
    
    if let categoryID = expenseDictionary["category"] as? String {
      self.category = BKCategory.fetchCategory(withCloudID: categoryID)
    }
    
    return true
  }
}

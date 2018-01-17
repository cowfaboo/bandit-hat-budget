//
//  BKCategory+CoreDataClass.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-03.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(BKCategory)
public class BKCategory: NSManagedObject {
  
  public var color: UIColor {
    get {
      return UIColor(hexString: colorString)
    }
  }
  
  public class func createOrUpdate(with categoryDictionary: Dictionary<String, AnyObject>) -> BKCategory? {
    
    guard let cloudID = categoryDictionary["_id"] as? String else {
      return nil
    }
    
    if let category = fetchCategory(withCloudID: cloudID) {
      let _ = category.configure(with: categoryDictionary)
      return category
    }
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    
    let category = NSEntityDescription.insertNewObject(forEntityName: "BKCategory", into: viewContext) as! BKCategory
    if category.configure(with: categoryDictionary) {
      return category
    } else {
      return nil
    }
  }
  
  public class func fetchCategory(withCloudID cloudID: String) -> BKCategory? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKCategory> = self.fetchRequest()
    
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        let category = results.first!
        return category
      }
    }
    
    return nil
  }
  
  public class func fetchCategories() ->[BKCategory]? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKCategory> = self.fetchRequest()
    
    if let results = try? viewContext.fetch(fetchRequest) {
      return results
    }
    
    return nil
  }
  
  public class func deleteCategory(withCloudID cloudID: String) {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKCategory> = self.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    var category: BKCategory?
    
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        category = results.first
      }
    }
    
    guard category != nil else {
      return
    }
    
    do {
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
      try BKSharedDataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: BKSharedDataController.persistentContainer.viewContext)
      BKSharedDataController.saveContext()
      
    } catch {
      print("failed to properly delete category locally")
    }
  }
  
  func configure(with categoryDictionary: Dictionary<String, AnyObject>) -> Bool {
    
    guard let cloudID = categoryDictionary["_id"] as? String,
      let name = categoryDictionary["name"] as? String,
      let colorString = categoryDictionary["color"] as? String,
      let dateCreatedString = categoryDictionary["createdAt"] as? String,
      let dateUpdatedString = categoryDictionary["updatedAt"] as? String else {
        return false
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString) else {
        return false
    }
    
    self.cloudID = cloudID
    self.name = name
    self.colorString = colorString
    self.dateCreated = dateCreated as NSDate
    self.dateUpdated = dateUpdated as NSDate
    
    if let details = categoryDictionary["description"] as? String {
      self.details = details
    }
    
    if let monthlyBudgetNumber = categoryDictionary["monthlyBudget"] as? NSNumber {
      self.monthlyBudget = Float(truncating: monthlyBudgetNumber)
    }
    
    return true
  }
}

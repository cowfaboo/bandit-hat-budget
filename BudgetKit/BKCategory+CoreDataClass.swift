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
    
    guard let cloudID = categoryDictionary["id"] as? Int64 else {
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
  
  public class func fetchCategory(withCloudID cloudID: Int64) -> BKCategory? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKCategory> = self.fetchRequest()
    
    fetchRequest.predicate = NSPredicate(format: "cloudID == %ld", cloudID)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        let category = results.first!
        return category
      }
    }
    
    return nil
  }
  
  func configure(with categoryDictionary: Dictionary<String, AnyObject>) -> Bool {
    
    guard let cloudID = categoryDictionary["id"] as? Int,
      let name = categoryDictionary["name"] as? String,
      let colorString = categoryDictionary["color"] as? String,
      let dateCreatedString = categoryDictionary["created_at"] as? String,
      let dateUpdatedString = categoryDictionary["updated_at"] as? String else {
        return false
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString) else {
        return false
    }
    
    self.cloudID = Int64(cloudID)
    self.name = name
    self.colorString = colorString
    self.dateCreated = dateCreated as NSDate
    self.dateUpdated = dateUpdated as NSDate
    
    if let details = categoryDictionary["description"] as? String {
      self.details = details
    }
    
    if let monthlyBudgetString = categoryDictionary["monthly_budget"] as? String {
      if let monthlyBudget = Float(monthlyBudgetString) {
        self.monthlyBudget = monthlyBudget
      }
    }
    
    return true
  }
}

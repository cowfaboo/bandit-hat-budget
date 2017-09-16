//
//  BKGroup+CoreDataClass.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-09-12.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import Foundation
import CoreData

@objc(BKGroup)
public class BKGroup: NSManagedObject {

  public class func createOrUpdate(with groupDictionary: Dictionary<String, AnyObject>) -> BKGroup? {
    
    guard let cloudID = groupDictionary["_id"] as? String else {
      return nil
    }
    
    if let group = fetchGroup(withCloudID: cloudID) {
      let _ = group.configure(with: groupDictionary)
      return group
    }
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    
    let group = NSEntityDescription.insertNewObject(forEntityName: "BKGroup", into: viewContext) as! BKGroup
    if group.configure(with: groupDictionary) {
      return group
    } else {
      return nil
    }
  }
  
  public class func currentGroup() -> BKGroup? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKGroup> = self.fetchRequest()
    var group: BKGroup?
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        group = results.first
      }
    }
    
    return group
  }
  
  public class func signedIn() -> Bool {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKGroup> = self.fetchRequest()
    var group: BKGroup?
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        group = results.first
      }
    }
    
    guard let currentGroup = group else {
      return false
    }
    
    let passwordItem = KeychainPasswordItem(service: "BudgetKit", account: currentGroup.name!, accessGroup: nil)
    let password = try? passwordItem.readPassword()
    
    if (password != nil) {
      return true
    } else {
      return false
    }
  }
  
  public class func signOut() {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKGroup> = self.fetchRequest()
    var group: BKGroup?
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        group = results.first
      }
    }
    
    guard let currentGroup = group else {
      return
    }
    
    do {
      
      let passwordItem = KeychainPasswordItem(service: "BudgetKit", account: currentGroup.name!, accessGroup: nil)
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
      try BKSharedDataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: BKSharedDataController.persistentContainer.viewContext)
      try passwordItem.deleteItem()
      
    } catch {
      print("failed to properly sign out")
    }
  }
  
  public class func fetchGroup(withCloudID cloudID: String) -> BKGroup? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKGroup> = self.fetchRequest()
    
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        let group = results.first!
        return group
      }
    }
    
    return nil
  }
  
  func configure(with groupDictionary: Dictionary<String, AnyObject>) -> Bool {
    
    guard let cloudID = groupDictionary["_id"] as? String,
      let name = groupDictionary["name"] as? String,
      let password = groupDictionary["password"] as? String,
      let dateCreatedString = groupDictionary["createdAt"] as? String,
      let dateUpdatedString = groupDictionary["updatedAt"] as? String else {
        return false
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString) else {
        return false
    }
    
    self.cloudID = cloudID
    self.name = name
    self.dateCreated = dateCreated as NSDate
    self.dateUpdated = dateUpdated as NSDate
    
    let passwordItem = KeychainPasswordItem(service: "BudgetKit",
                                            account: name,
                                            accessGroup: nil)
    
    try! passwordItem.savePassword(password)
    
    return true
  }
}

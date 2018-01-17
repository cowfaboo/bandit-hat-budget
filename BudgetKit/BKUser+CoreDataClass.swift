//
//  BKUser+CoreDataClass.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-03.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData

@objc(BKUser)
public class BKUser: NSManagedObject {

  public class func createOrUpdate(with userDictionary: Dictionary<String, AnyObject>) -> BKUser? {
    
    guard let cloudID = userDictionary["_id"] as? String else {
      return nil
    }
    
    if let user = fetchUser(withCloudID: cloudID) {
      let _ = user.configure(with: userDictionary)
      return user
    }
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    
    let user = NSEntityDescription.insertNewObject(forEntityName: "BKUser", into: viewContext) as! BKUser
    if user.configure(with: userDictionary) {
      return user
    } else {
      return nil
    }
  }
  
  public class func fetchUser(withCloudID cloudID: String) -> BKUser? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKUser> = self.fetchRequest()
    
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        let user = results.first!
        return user
      }
    }
    
    return nil
  }
  
  public class func fetchUsers() ->[BKUser]? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKUser> = self.fetchRequest()
    
    if let results = try? viewContext.fetch(fetchRequest) {
      return results
    }
    
    return nil
  }
  
  public class func deleteUser(withCloudID cloudID: String) {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKUser> = self.fetchRequest()
    fetchRequest.predicate = NSPredicate(format: "cloudID == %@", cloudID)
    var user: BKUser?
    
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        user = results.first
      }
    }
    
    guard user != nil else {
      return
    }
    
    do {
      let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest as! NSFetchRequest<NSFetchRequestResult>)
      try BKSharedDataController.persistentContainer.persistentStoreCoordinator.execute(deleteRequest, with: BKSharedDataController.persistentContainer.viewContext)
      BKSharedDataController.saveContext()
      
    } catch {
      print("failed to properly delete user locally")
    }
  }
  
  func configure(with userDictionary: Dictionary<String, AnyObject>) -> Bool {
    
    guard let cloudID = userDictionary["_id"] as? String,
      let name = userDictionary["name"] as? String,
      let dateCreatedString = userDictionary["createdAt"] as? String,
      let dateUpdatedString = userDictionary["updatedAt"] as? String else {
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
  
    return true
  }
}

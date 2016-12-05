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
    
    guard let cloudID = userDictionary["id"] as? Int64 else {
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
  
  public class func fetchUser(withCloudID cloudID: Int64) -> BKUser? {
    
    let viewContext = BKSharedDataController.persistentContainer.viewContext
    let fetchRequest: NSFetchRequest<BKUser> = self.fetchRequest()
    
    fetchRequest.predicate = NSPredicate(format: "cloudID == %ld", cloudID)
    
    if let results = try? viewContext.fetch(fetchRequest) {
      if results.count > 0 {
        let user = results.first!
        return user
      }
    }
    
    return nil
  }
  
  func configure(with userDictionary: Dictionary<String, AnyObject>) -> Bool {
    
    guard let cloudID = userDictionary["id"] as? Int,
      let name = userDictionary["name"] as? String,
      let dateCreatedString = userDictionary["created_at"] as? String,
      let dateUpdatedString = userDictionary["updated_at"] as? String else {
        return false
    }
    
    guard let dateCreated = BKUtilities.dateTime(from: dateCreatedString),
      let dateUpdated = BKUtilities.dateTime(from: dateUpdatedString) else {
        return false
    }
    
    self.cloudID = Int64(cloudID)
    self.name = name
    self.dateCreated = dateCreated as NSDate
    self.dateUpdated = dateUpdated as NSDate
  
    return true
  }
}

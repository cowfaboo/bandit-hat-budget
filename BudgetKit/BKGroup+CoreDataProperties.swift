//
//  BKGroup+CoreDataProperties.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-09-12.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import Foundation
import CoreData


extension BKGroup {
  
  @nonobjc public class func fetchRequest() -> NSFetchRequest<BKGroup> {
    return NSFetchRequest<BKGroup>(entityName: "BKGroup")
  }
  
  @NSManaged public var cloudID: String
  @NSManaged public var name: String?
  @NSManaged var dateCreated: NSDate
  @NSManaged var dateUpdated: NSDate
  
  var password: String? {
    get {
      
      guard let name = name else {
        return nil;
      }
      
      let passwordItem = KeychainPasswordItem(service: "BudgetKit",
                                              account: name,
                                              accessGroup: nil)
      if let password = try? passwordItem.readPassword() {
        return password
      } else {
        return nil
      }
    }
  }
  
}

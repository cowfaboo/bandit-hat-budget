//
//  BKUser.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

public class BKUser {
  
  public var cloudID: Int
  public var name: String
  public var dateCreated: Date
  public var dateUpdated: Date
  
  init?(userDictionary: Dictionary<String, AnyObject>) {
    
    guard let cloudID = userDictionary["id"] as? Int,
          let name = userDictionary["name"] as? String,
          let dateCreatedString = userDictionary["created_at"] as? String,
          let dateUpdatedString = userDictionary["updated_at"] as? String else {
            return nil
    }
    
    guard let dateCreated = BKUtilities.date(from: dateCreatedString),
          let dateUpdated = BKUtilities.date(from: dateUpdatedString) else {
            return nil
    }
    
    self.cloudID = cloudID
    self.name = name
    self.dateCreated = dateCreated
    self.dateUpdated = dateUpdated
  }
}

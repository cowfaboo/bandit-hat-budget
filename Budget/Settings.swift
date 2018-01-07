//
//  Settings.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation
import BudgetKit

let UserIDKey = "UserID"
let GroupIDKey = "GroupID"

class Settings {
  
  class func hasClaimedUser() -> Bool {
    //return false
    if UserDefaults.standard.string(forKey: UserIDKey) == nil {
      return false
    }
    return true
  }
  
  class func claimedUserID() -> String? {
    return UserDefaults.standard.string(forKey: UserIDKey)
  }
  
  class func claimUser(_ user: BKUser) {
    UserDefaults.standard.set(user.cloudID, forKey: UserIDKey)
  }
  
  class func relinquishUser() {
    UserDefaults.standard.set(nil, forKey: UserIDKey)
  }
}

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

class Settings {
  
  class func signedIn() -> Bool {
    if UserDefaults.standard.integer(forKey: UserIDKey) == 0 {
      return false
    }
    return true
  }
  
  class func currentUserID() -> Int64 {
    return Int64(UserDefaults.standard.integer(forKey: UserIDKey))
  }
  
  class func signInWithUser(_ user: BKUser) {
    UserDefaults.standard.set(user.cloudID, forKey: UserIDKey)
  }
  
  class func signOut() {
    UserDefaults.standard.set(0, forKey: UserIDKey)
  }
}

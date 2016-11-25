//
//  BKUtilities.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

public class BKUtilities {
  
  class func date(from string: String) -> Date? {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    if let dateCreated = dateFormatter.date(from: string) {
      return dateCreated
    }
    
    return nil
  }
}

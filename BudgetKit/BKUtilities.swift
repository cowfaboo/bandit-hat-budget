//
//  BKUtilities.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-25.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

public class BKUtilities {
  
  class func dateTime(from string: String) -> Date? {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    if let date = dateFormatter.date(from: string) {
      return date
    }
    
    return nil
  }
  
  class func date(from string: String) -> Date? {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    if let date = dateFormatter.date(from: string) {
      return date
    }
    
    return nil
  }
  
  class func dateString(from date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd"
    return dateFormatter.string(from: date)
  }
  
  class func dateTimeString(from date: Date) -> String {
    
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
    dateFormatter.timeZone = TimeZone(identifier: "UTC")
    return dateFormatter.string(from: date)
  }
}

extension UIColor {
  
  public convenience init(hexString: String) {
    var sanitizedString = hexString.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    if sanitizedString.hasPrefix("#") {
      sanitizedString.remove(at: sanitizedString.startIndex)
    }
    
    if sanitizedString.characters.count != 6 {
      self.init(white: 0.25, alpha: 1.0)
    } else {
      var rgbValue: UInt32 = 0
      Scanner(string: sanitizedString).scanHexInt32(&rgbValue)
      self.init(red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
                green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
                blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
                alpha: CGFloat(1.0))
    }
  }
}


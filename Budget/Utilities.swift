//
//  Utilities.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-03.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

enum TimeRangeType {
  case monthly
  case annual
}

enum DataPresentationType {
  case amounts
  case expenses
}

let DataViewNeedsUpdateKey = "DataViewNeedsUpdate"

class Utilities {
  
  class func getStartAndEndOfMonth(from date: Date) -> (startDate: Date, endDate: Date) {
    
    let dateComponents = Calendar.current.dateComponents([.month, .year], from: date)
    let dayRange = Calendar.current.range(of: .day, in: .month, for: date)
    
    var startDateComponents = dateComponents
    var endDateComponents = dateComponents
    startDateComponents.day = 1
    endDateComponents.day = dayRange!.upperBound - 1
    
    let startDate = Calendar.current.date(from: startDateComponents)
    let endDate = Calendar.current.date(from: endDateComponents)
    
    return (startDate!, endDate!)
  }
  
  class func getStartAndEndOfYear(from date: Date) -> (startDate: Date, endDate: Date) {
    
    let dateComponents = Calendar.current.dateComponents([.year], from: date)
    
    var startDateComponents = dateComponents
    var endDateComponents = dateComponents
    startDateComponents.day = 1
    startDateComponents.month = 1
    endDateComponents.day = 31
    endDateComponents.month = 12
    
    let startDate = Calendar.current.date(from: startDateComponents)
    let endDate = Calendar.current.date(from: endDateComponents)
    
    return (startDate!, endDate!)
  }
  
  class func getStartOfPreviousMonth(from date: Date) -> Date {
    
    var dateComponents = Calendar.current.dateComponents([.month, .year], from: date)
    dateComponents.day = 1
    dateComponents.month! -= 1
    
    let date = Calendar.current.date(from: dateComponents)
    
    return date!
  }
  
  class func getStartOfNextMonth(from date: Date) -> Date {
    
    var dateComponents = Calendar.current.dateComponents([.month, .year], from: date)
    dateComponents.day = 1
    dateComponents.month! += 1
    
    let date = Calendar.current.date(from: dateComponents)
    
    return date!
  }
  
  class func getMonthYearString(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: date)
  }
  
  class func getYearString(from date: Date) -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: date)
  }
  
  class func dataViewNeedsUpdate() -> Bool {
    let dataViewNeedsUpdate = UserDefaults.standard.bool(forKey: DataViewNeedsUpdateKey)
    UserDefaults.standard.set(false, forKey: DataViewNeedsUpdateKey)
    return dataViewNeedsUpdate
  }
  
  class func setDataViewNeedsUpdate() {
    UserDefaults.standard.set(true, forKey: DataViewNeedsUpdateKey)
  }
}

extension Float {
  
  var dollarAmount: String {
    get {
      let numberFormatter = NumberFormatter()
      numberFormatter.minimumIntegerDigits = 1
      numberFormatter.minimumFractionDigits = 2
      numberFormatter.maximumFractionDigits = 2
      let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
      if let formattedNumber = formattedNumber {
        return "$\(formattedNumber)"
      } else {
        return "\(self)"
      }
    }
  }
}

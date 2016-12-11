//
//  Utilities.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-03.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation
import UIKit

enum TimeRangeType {
  case monthly
  case annual
}

enum DataPresentationType {
  case amounts
  case expenses
}

let DataViewNeedsUpdateKey = "DataViewNeedsUpdate"

let Colors = [#colorLiteral(red: 0.1176470588, green: 0.2196078431, blue: 0.3921568627, alpha: 1), #colorLiteral(red: 0.9490196078, green: 0.3019607843, blue: 0.1607843137, alpha: 1), #colorLiteral(red: 0.2705882353, green: 0.3882352941, blue: 0.3333333333, alpha: 1), #colorLiteral(red: 0.4168243387, green: 0.3121102968, blue: 0.5244659871, alpha: 1), #colorLiteral(red: 0, green: 0.6274509804, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.3568627451, green: 0.737254902, blue: 0.8392156863, alpha: 1), #colorLiteral(red: 0.8941176471, green: 0.3843137255, blue: 0.4, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.721568644, blue: 0.3647058904, alpha: 1), #colorLiteral(red: 0.6784313725, green: 0.2039215686, blue: 0.2431372549, alpha: 1), #colorLiteral(red: 0.9803921569, green: 0.6392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.6156862745, blue: 0.5176470588, alpha: 1), #colorLiteral(red: 0.3490196078, green: 0.5843137255, blue: 0.9294117647, alpha: 1)]

let TextColor = UIColor(white: 0.3, alpha: 1.0)

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
  
  class func getRandomColor() -> UIColor {
    return Colors[Int(arc4random_uniform(UInt32(Colors.count)))]
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

extension UIColor {
  
  class var text: UIColor {
    get {
      return UIColor(white: 0.25, alpha: 1.0)
    }
  }
}

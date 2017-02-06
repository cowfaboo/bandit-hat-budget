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

let Colors = [#colorLiteral(red: 0.1176470588, green: 0.2196078431, blue: 0.3921568627, alpha: 1), #colorLiteral(red: 0.2705882353, green: 0.3882352941, blue: 0.3333333333, alpha: 1), #colorLiteral(red: 0.4168243387, green: 0.3121102968, blue: 0.5244659871, alpha: 1), #colorLiteral(red: 0, green: 0.6274509804, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.3568627451, green: 0.737254902, blue: 0.8392156863, alpha: 1), #colorLiteral(red: 0.8941176471, green: 0.3843137255, blue: 0.4, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.721568644, blue: 0.3647058904, alpha: 1), #colorLiteral(red: 0.6784313725, green: 0.2039215686, blue: 0.2431372549, alpha: 1), #colorLiteral(red: 0.9803921569, green: 0.6392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.6156862745, blue: 0.5176470588, alpha: 1), #colorLiteral(red: 0.3490196078, green: 0.5843137255, blue: 0.9294117647, alpha: 1)]

class Utilities {
  
  class var screenWidth: CGFloat {
    get {
      return UIScreen.main.bounds.width
    }
  }
  
  class var screenHeight: CGFloat {
    get {
      return UIScreen.main.bounds.height
    }
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

extension String {
  
  func isCompleteDollarAmount() -> Bool {
    
    if Float(self) != nil {
      let decimalArray = self.characters.split(separator: ".")
      if decimalArray.count == 2 && decimalArray[1].count == 2 {
        return true
      }
    }
    
    return false
  }
}

extension Date {
  
  func isMonthEqualTo(_ comparisonDate: Date) -> Bool {
    let firstDateComponents = Calendar.current.dateComponents([.month, .year], from: self)
    let secondDateComponents = Calendar.current.dateComponents([.month, .year], from: comparisonDate)
    
    if firstDateComponents.year == secondDateComponents.year && firstDateComponents.month == secondDateComponents.month {
      return true
    }
    
    return false
  }
  
  func isYearEqualTo(_ comparisonDate: Date) -> Bool {
    let firstDateComponents = Calendar.current.dateComponents([.year], from: self)
    let secondDateComponents = Calendar.current.dateComponents([.year], from: comparisonDate)
    
    if firstDateComponents.year == secondDateComponents.year {
      return true
    }
    
    return false
  }
  
  func completionPercentageOfMonth() -> Float {
    let dayRange = Calendar.current.range(of: .day, in: .month, for: self)
    let lastDate = dayRange!.upperBound - 1
    
    let dateComponents = Calendar.current.dateComponents([.day], from: self)
    let currentDate = dateComponents.day
    
    if let currentDate = currentDate {
      return Float(currentDate - 1) / Float(lastDate)
    }
    
    return 0
  }
  
  func numberOfDaysInYear() -> Int {
    var dateComponents = Calendar.current.dateComponents([.year], from: self)
    dateComponents.month = 12
    dateComponents.day = 31
    
    let lastDate = Calendar.current.date(from: dateComponents)
    
    if let lastDate = lastDate {
      return Calendar.current.ordinality(of: .day, in: .year, for: lastDate)!
    }
    
    return 365
  }
  
  func dayOfMonth() -> Int {
    
    let dateComponents = Calendar.current.dateComponents([.day], from: self)
    return dateComponents.day!
  }
  
  func completionPercentageOfYear() -> Float {
    let lastDate = self.numberOfDaysInYear()
    
    let currentDate = Calendar.current.ordinality(of: .day, in: .year, for: self)
    
    if let currentDate = currentDate {
      return Float(currentDate - 1) / Float(lastDate)
    }
    
    return 0
  }
  
  func startAndEndOfMonth() -> (startDate: Date, endDate: Date) {
    
    let dateComponents = Calendar.current.dateComponents([.month, .year], from: self)
    let dayRange = Calendar.current.range(of: .day, in: .month, for: self)
    
    var startDateComponents = dateComponents
    var endDateComponents = dateComponents
    startDateComponents.day = 1
    endDateComponents.day = dayRange!.upperBound - 1
    
    let startDate = Calendar.current.date(from: startDateComponents)
    let endDate = Calendar.current.date(from: endDateComponents)
    
    return (startDate!, endDate!)
  }
  
  func startAndEndOfYear() -> (startDate: Date, endDate: Date) {
    
    let dateComponents = Calendar.current.dateComponents([.year], from: self)
    
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
  
  func startOfPreviousMonth() -> Date {
    
    var dateComponents = Calendar.current.dateComponents([.month, .year], from: self)
    dateComponents.day = 1
    dateComponents.month! -= 1
    
    let date = Calendar.current.date(from: dateComponents)
    
    return date!
  }
  
  func startOfNextMonth() -> Date {
    
    var dateComponents = Calendar.current.dateComponents([.month, .year], from: self)
    dateComponents.day = 1
    dateComponents.month! += 1
    
    let date = Calendar.current.date(from: dateComponents)
    
    return date!
  }
  
  func monthYearString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM yyyy"
    return dateFormatter.string(from: self)
  }
  
  func yearString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: self)
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
  
  var simpleDollarAmount: String {
    get {
      let numberFormatter = NumberFormatter()
      numberFormatter.roundingMode = .up
      numberFormatter.minimumIntegerDigits = 1
      numberFormatter.minimumFractionDigits = 0
      numberFormatter.maximumFractionDigits = 0
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
  
  class var overBudget: UIColor {
    get {
      return #colorLiteral(red: 0.9490196078, green: 0.3019607843, blue: 0.1607843137, alpha: 1)
    }
  }
}

extension UIViewController {
  
  func add(_ viewController: UIViewController, to containerView: UIView, withAnimatedTransition shouldAnimateTransition: Bool = false) {
    
    addChildViewController(viewController)
    viewController.view.frame = containerView.bounds
    containerView.addSubview(viewController.view)
    viewController.didMove(toParentViewController: self)
    
    if shouldAnimateTransition, let dataDisplayingViewController = viewController as? DataDisplaying {
      dataDisplayingViewController.fadeIn(completion: nil)
    }
  }
  
  func removeFromContainerView() {
    willMove(toParentViewController: nil)
    removeFromParentViewController()
    view.removeFromSuperview()
  }
}

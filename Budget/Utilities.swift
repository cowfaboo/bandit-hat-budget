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

//let Colors = [#colorLiteral(red: 0.1176470588, green: 0.2196078431, blue: 0.3921568627, alpha: 1), #colorLiteral(red: 0.2705882353, green: 0.3882352941, blue: 0.3333333333, alpha: 1), #colorLiteral(red: 0.4168243387, green: 0.3121102968, blue: 0.5244659871, alpha: 1), #colorLiteral(red: 0, green: 0.6274509804, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 0.3568627451, green: 0.737254902, blue: 0.8392156863, alpha: 1), #colorLiteral(red: 0.8941176471, green: 0.3843137255, blue: 0.4, alpha: 1), #colorLiteral(red: 0.2745098174, green: 0.721568644, blue: 0.3647058904, alpha: 1), #colorLiteral(red: 0.6784313725, green: 0.2039215686, blue: 0.2431372549, alpha: 1), #colorLiteral(red: 0.9803921569, green: 0.6392156863, blue: 0, alpha: 1), #colorLiteral(red: 0.968627451, green: 0.6156862745, blue: 0.5176470588, alpha: 1), #colorLiteral(red: 0.3490196078, green: 0.5843137255, blue: 0.9294117647, alpha: 1)]

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
  
  func sanitizeHouseholdName() -> String {
    
    let sanitizedString = self.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let components = sanitizedString.components(separatedBy: NSCharacterSet.whitespacesAndNewlines)
    return components.filter { !$0.isEmpty }.joined(separator: " ")
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
  
  func isDateEqualTo(_ comparisonDate: Date) -> Bool {
    let firstDateComponents = Calendar.current.dateComponents([.month, .year, .day], from: self)
    let secondDateComponents = Calendar.current.dateComponents([.month, .year, .day], from: comparisonDate)
    
    if firstDateComponents.year == secondDateComponents.year && firstDateComponents.month == secondDateComponents.month && firstDateComponents.day == secondDateComponents.day {
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
  
  func monthDayYearString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "MMMM d yyyy"
    return dateFormatter.string(from: self)
  }
  
  func yearString() -> String {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "yyyy"
    return dateFormatter.string(from: self)
  }
  
}

extension Float {
  
  /*var dollarAmount: String {
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
  }*/
  
  /*var simpleDollarAmount: String {
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
  }*/
  
  func dollarAmount(withDollarSign: Bool = false) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.minimumFractionDigits = 2
    numberFormatter.maximumFractionDigits = 2
    let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
    if let formattedNumber = formattedNumber {
      if withDollarSign {
        return "$\(formattedNumber)"
      } else {
        return "\(formattedNumber)"
      }
    } else {
      return "\(self)"
    }
  }
  
  func simpleDollarAmount(withDollarSign: Bool = true) -> String {
    let numberFormatter = NumberFormatter()
    numberFormatter.roundingMode = .up
    numberFormatter.minimumIntegerDigits = 1
    numberFormatter.minimumFractionDigits = 0
    numberFormatter.maximumFractionDigits = 0
    let formattedNumber = numberFormatter.string(from: NSNumber(value: self))
    if let formattedNumber = formattedNumber {
      if withDollarSign {
        return "$\(formattedNumber)"
      } else {
        return "\(formattedNumber)"
      }
      
    } else {
      return "\(self)"
    }
  }
}

extension UIColor {
  
  class var text: UIColor {
    get {
      return UIColor(white: 0.25, alpha: 1.0)
    }
  }
  
  class var negative: UIColor {
    get {
      return #colorLiteral(red: 0.8431372549, green: 0.2274509804, blue: 0.1921568627, alpha: 1)
    }
  }
  
  class var positive: UIColor {
    get {
      return #colorLiteral(red: 0.3450980392, green: 0.7176470588, blue: 0.3764705882, alpha: 1)
    }
  }
  
  class var palette: Array<UIColor> {
    get {
      return [#colorLiteral(red: 0.2901960784, green: 0.6, blue: 0.8941176471, alpha: 1), #colorLiteral(red: 0.9921568627, green: 0.5960784314, blue: 0.1529411765, alpha: 1), #colorLiteral(red: 0.1254901961, green: 0.5882352941, blue: 0.7294117647, alpha: 1), #colorLiteral(red: 0.9137254902, green: 0.7803921569, blue: 0.1333333333, alpha: 1), #colorLiteral(red: 0.1411764706, green: 0.7176470588, blue: 0.7098039216, alpha: 1), #colorLiteral(red: 0.462745098, green: 0.3215686275, blue: 0.5215686275, alpha: 1), #colorLiteral(red: 0.8, green: 0.4, blue: 0.1254901961, alpha: 1), #colorLiteral(red: 0.8352941176, green: 0.4392156863, blue: 0.7411764706, alpha: 1), #colorLiteral(red: 0.4196078431, green: 0.5098039216, blue: 0.6588235294, alpha: 1), #colorLiteral(red: 0.03137254902, green: 0.4392156863, blue: 0.5411764706, alpha: 1), #colorLiteral(red: 1, green: 0.5490196078, blue: 0.6823529412, alpha: 1), #colorLiteral(red: 0.7019607843, green: 0.4862745098, blue: 0.3411764706, alpha: 1)]
    }
  }
  
  class func paletteIndex(of color: UIColor) -> Int? {
    let hexValue = color.hexString.uppercased()
    
    switch hexValue {
    case "4A99E4":
      return 0
    case "FD9827":
      return 1
    case "2096BA":
      return 2
    case "E9C722":
      return 3
    case "24B7B5":
      return 4
    case "765285":
      return 5
    case "CC6620":
      return 6
    case "D570BD":
      return 7
    case "6B82A8":
      return 8
    case "08708A":
      return 9
    case "FF8CAE":
      return 10
    case "B37C57":
      return 11
    default:
      return nil
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
  
  func presentSimpleAlert(withTitle title: String, andMessage message: String) {
    
    guard let presentingViewController = self as? (TopSlideDelegate & InteractivePresenter & UIViewControllerTransitioningDelegate) else {
      return
    }
    
    let confirmAction = BHAlertAction(withTitle: "Got It", action: {
      self.dismiss(animated: true, completion: nil)
    })
    
    let alertViewController = BHAlertViewController(withTitle: title, message: message, actions: [confirmAction])
    let topSlideViewController = TopSlideViewController(presenting: alertViewController, from: presentingViewController)
    present(topSlideViewController, animated: true, completion: nil)
  }
}

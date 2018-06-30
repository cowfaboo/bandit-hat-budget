//
//  DataDisplaying.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-01-31.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import Foundation
import BudgetKit

protocol DataDisplaying: class {
  var userFilter: BKUser? { get set }
  var startDate: Date { get set }
  var endDate: Date { get set }
  //var timeRangeType: TimeRangeType { get }
  
  func fadeOut(completion: (() -> ())?)
  func fadeIn(completion: (() -> ())?)
  func scrollToTop()
  func updateData()
}

/*extension DataDisplaying {
  var timeRangeType: TimeRangeType {
    if startDate.monthYearString() == endDate.monthYearString() {
      return .monthly
    } else if startDate.yearString() == endDate.yearString() {
      return .annual
    } else {
      return .other
    }
  }
}*/

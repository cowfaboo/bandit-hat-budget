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
  
  func updateData()
  func fadeOut(completion: (() -> ())?)
  func fadeIn(completion: (() -> ())?)
}

//
//  TopLevelNavigable.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-11-18.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import Foundation

protocol TopLevelNavigable: class {
  var topLevelNavigationController: TopLevelNavigationController? { get set }
}


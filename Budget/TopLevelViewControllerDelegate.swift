//
//  TopLevelViewControllerDelegate.swift
//  Budget
//
//  Created by Daniel Gauthier on 2018-01-01.
//  Copyright © 2018 Bandit Hat Apps. All rights reserved.
//

import Foundation

protocol TopLevelViewControllerDelegate: class {
  func topLevelViewControllerDismissed(_ topLevelViewController: TopLevelViewController)
}

extension TopLevelViewControllerDelegate where Self: UIViewController  {
  func topLevelViewControllerDismissed(_ topLevelViewController: TopLevelViewController) {
    // default implementation simply dismisses presented view controller
    dismiss(animated: true)
  }
}

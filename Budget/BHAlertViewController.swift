//
//  BHAlertViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2017-04-22.
//  Copyright © 2017 Bandit Hat Apps. All rights reserved.
//

import UIKit

class BHAlertViewController: UIViewController {
  
  @IBOutlet var titleLabel: UILabel!
  @IBOutlet var messageLabel: UILabel!
  @IBOutlet var buttonStackView: UIStackView!
  var actionButtons: [BHButton] = []
  
  var actions: [BHAlertAction] = []
  var alertTitle: String = ""
  var alertMessage: String = ""
  
  var laidOutSubviews = false
  
  
  init(withTitle title: String, message: String, actions: [BHAlertAction]) {
    super.init(nibName: "BHAlertViewController", bundle: nil)
    
    alertTitle = title
    alertMessage = message
    self.actions = actions
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }
  
  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    titleLabel.text = alertTitle
    messageLabel.text = alertMessage
    
    for action in actions {
      let button = BHButton()
      button.setTitle(action.title, for: .normal)
      button.titleLabel?.font = UIFont.systemFont(ofSize: 18.0, weight: UIFont.Weight.medium)
      button.themeColor = action.color
      button.addTarget(self, action: #selector(actionButtonTapped(sender:)), for: .touchUpInside)
      buttonStackView.addArrangedSubview(button)
      actionButtons.append(button)
    }
  }
  
  override func viewDidLayoutSubviews() {
    
    if laidOutSubviews {
      return
    }
    
    laidOutSubviews = true
    
    if let viewContainer = self.parent as? ViewContainer {
      messageLabel.preferredMaxLayoutWidth = view.frame.size.width - 32
      titleLabel.preferredMaxLayoutWidth = view.frame.size.width - 32
      let size = view.systemLayoutSizeFitting(UILayoutFittingExpandedSize)
      viewContainer.contentHeightDidChange(size.height)
    }
  }
  
  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
  }
  
  
  @objc func actionButtonTapped(sender: BHButton) {
    
    if let index = actionButtons.index(of: sender) {
      let action = actions[index]
      action.action()
    }
  }
}

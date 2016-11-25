//
//  UserSelectionViewController.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit
import BudgetKit

class UserSelectionViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

      BKSharedBasicRequestClient.getUsers { (success: Bool, userArray: Array<BKUser>?) in
        
        if success {
          for user in userArray! {
            print(user.name)
            print(user.cloudID)
            print(user.dateCreated)
            print(user.dateUpdated)
          }
          
        } else {
          print("failed to get users")
        }
      }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

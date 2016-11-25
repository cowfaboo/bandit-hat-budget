//
//  BKBasicRequestClient.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

public class BKBasicRequestClient: BKClient {

  static let sharedInstance = BKBasicRequestClient()
  
  public func getUsers(completion: @escaping BKGetUsersCompletionBlock) {
    
    let endpoint = UsersEndpoint
    let method = "GET"
    let requestDescription = "getUsers"
    
    makeAPICallToEndpoint(endpoint, method: method, requestDescription: requestDescription) { (success, response, responseData) -> () in
      
      if success {
        
        let userDictionaryArray = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! Array<[String: AnyObject]>
        var userArray = [BKUser]()
        
        for user in userDictionaryArray {
          if let bkUser = BKUser(userDictionary: user) {
            userArray.append(bkUser)
          }
        }
        
        completion(true, userArray)
        
      } else {
        completion(false, nil)
      }
    }
  }
}

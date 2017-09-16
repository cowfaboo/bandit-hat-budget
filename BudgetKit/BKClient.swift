//
//  BKClient.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

public typealias BKGenericAPICallCompletionBlock = (_ success: Bool, _ response: HTTPURLResponse?, _ responseData: Data?, _ errorType: BKAPIErrorType?, _ errorMessage: String?) -> ()

public enum BKAPIErrorType {
  case requestFailed
  case noResponse
  case badRequest
  case notFound
  case internalServer
  case unauthorized
  case unknown
  case clientProcessing
}

public class BKClient: NSObject, URLSessionDataDelegate, URLSessionDelegate {

  var session: URLSession!
  
  public override init() {
    super.init()
    
    let sessionConfiguration = URLSessionConfiguration.default
    session = URLSession(configuration: sessionConfiguration, delegate: self, delegateQueue: OperationQueue.main)
  }
  
  func makeAPICallToEndpoint (
    _ endpoint: String,
    method: String,
    parameterString: String? = nil,
    body: Data? = nil,
    requestDescription: String? = nil,
    customAuthorizationHeader: String? = nil,
    completion: @escaping BKGenericAPICallCompletionBlock) {
    
    var requestURLString: String
    
    if parameterString == nil {
      requestURLString = endpoint
    } else {
      requestURLString = endpoint + "?" + parameterString!
    }
    
    let url = URL(string: requestURLString)!
    var request = URLRequest(url: url)
    request.httpMethod = method
    
    if let body = body {
      request.httpBody = body
    }
    
    if let customAuthorizationHeader = customAuthorizationHeader {
      
      request.addValue(customAuthorizationHeader, forHTTPHeaderField: "Authorization")
      
    } else if (BKGroup.signedIn()) {
      
      let currentGroup = BKGroup.currentGroup()
      
      if let groupName = currentGroup?.name, let groupPassword = currentGroup?.password {
        
        if let authorizationHeader = BKUtilities.authorizationHeader(fromUsername: groupName, andPassword: groupPassword) {
          request.addValue(authorizationHeader, forHTTPHeaderField: "Authorization")
        }
        
      } else {
        // probably want to do something here to sign out and prompt the user to sign in again
      }
    }
    
    request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    
    let dataTask = self.session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      
      if error != nil {
        if let requestDescription = requestDescription {
          print("\(requestDescription) ERROR \(error!)")
        } else {
          print("unknown API call ERROR \(error!)")
        }
        completion(false, nil, nil, .requestFailed, nil)
        return
      }
      
      if let response = response as? HTTPURLResponse {
        
        if let requestDescription = requestDescription {
          print("\(requestDescription) RESPONSE \(response.statusCode)")
        } else {
          print("unknown API call RESPONSE \(response.statusCode)")
        }
        
        if response.statusCode >= 200 && response.statusCode < 300 {
          completion(true, response, data, nil, nil)
          
        } else {
          
          var customErrorMessage: String? = nil
          if let data = data {
            print("\(String(data: data, encoding: String.Encoding.utf8)!)")
            if let dataDictionary = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: AnyObject] {
              customErrorMessage = dataDictionary["customErrorMessage"] as? String
            }
          }
          
          let apiErrorType: BKAPIErrorType
          if (response.statusCode == 400) {
            apiErrorType = .badRequest
          } else if (response.statusCode == 401) {
            apiErrorType = .unauthorized
          } else if (response.statusCode == 404) {
            apiErrorType = .notFound
          } else if (response.statusCode == 500) {
            apiErrorType = .internalServer
          } else {
            apiErrorType = .unknown
          }
          
          completion(false, response, nil, apiErrorType, customErrorMessage)
        }
      } else {
        if let requestDescription = requestDescription {
          print("\(requestDescription) NO RESPONSE")
        } else {
          print("unknown API call NO RESPONSE")
        }
        completion(false, nil, nil, .noResponse, nil)
      }
    })
    dataTask.resume()
  }
}

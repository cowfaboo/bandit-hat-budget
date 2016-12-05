//
//  BKClient.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import UIKit

public typealias BKGenericAPICallCompletionBlock = (_ success: Bool, _ response: HTTPURLResponse?, _ responseDate: Data?) -> ()

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
    
    
    let dataTask = self.session.dataTask(with: request, completionHandler: { (data, response, error) -> Void in
      
      if error != nil {
        if let requestDescription = requestDescription {
          print("\(requestDescription) ERROR \(error)")
        } else {
          print("unknown API call ERROR \(error)")
        }
        completion(false, nil, nil)
        return
      }
      
      if let response = response as? HTTPURLResponse {
        
        if let requestDescription = requestDescription {
          print("\(requestDescription) RESPONSE \(response.statusCode)")
        } else {
          print("unknown API call RESPONSE \(response.statusCode)")
        }
        
        if response.statusCode >= 200 && response.statusCode < 300 {
          completion(true, response, data)
          
        } else {
          
          if let data = data {
            print("\(String(data: data, encoding: String.Encoding.utf8))")
          }
          completion(false, nil, nil)
        }
      } else {
        if let requestDescription = requestDescription {
          print("\(requestDescription) NO RESPONSE")
        } else {
          print("unknown API call NO RESPONSE")
        }
        completion(false, nil, nil)
      }
    })
    dataTask.resume()
  }
}

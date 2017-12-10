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
  
  public func getCategories(completion: @escaping BKGetCategoriesCompletionBlock) {
    
    let endpoint = CategoryEndpoint
    let method = "GET"
    let requestDescription = "getCategories"
    
    makeAPICallToEndpoint(endpoint, method: method, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) -> () in
      
      if success {
        
        let categoryDictionaryArray = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! Array<[String: AnyObject]>
        var categoryArray = [BKCategory]()
        
        for categoryDictionary in categoryDictionaryArray {
          if let bkCategory = BKCategory.createOrUpdate(with: categoryDictionary) {
            categoryArray.append(bkCategory)
          }
        }
        
        completion(true, categoryArray)
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func getUsers(completion: @escaping BKGetUsersCompletionBlock) {
    
    let endpoint = UserEndpoint
    let method = "GET"
    let requestDescription = "getUsers"
    
    makeAPICallToEndpoint(endpoint, method: method, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) -> () in
      
      if success {
        
        let userDictionaryArray = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! Array<[String: AnyObject]>
        var userArray = [BKUser]()
        
        for userDictionary in userDictionaryArray {
          if let bkUser = BKUser.createOrUpdate(with: userDictionary) {
            userArray.append(bkUser)
          }
        }
        
        completion(true, userArray)
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func getExpenses(forUserID userID: String? = nil,
                                    categoryID: String? = nil,
                                    startDate: Date? = nil,
                                    endDate: Date? = nil,
                                    page: Int? = nil,
                                    completion: @escaping BKGetExpensesCompletionBlock) {
    
    var parameterString: String?
    
    var userParameterString: String?
    var categoryParameterString: String?
    var startDateParameterString: String?
    var endDateParameterString: String?
    var pageParameterString: String?
    
    if let userID = userID {
      userParameterString = "user_id=\(userID)"
    }
    
    if let categoryID = categoryID {
      categoryParameterString = "category_id=\(categoryID)"
    }
    
    if let startDate = startDate {
      let startDateString = BKUtilities.dateString(from: startDate)
      startDateParameterString = "start_date=\(startDateString)"
    }
    
    if let endDate = endDate {
      let endDateString = BKUtilities.dateString(from: endDate)
      endDateParameterString = "end_date=\(endDateString)"
    }
    
    if let page = page {
      pageParameterString = "per_page=25&page=\(page)"
    }
    
    if let userParameterString = userParameterString {
      parameterString = userParameterString
    }
    
    if let categoryParameterString = categoryParameterString {
      if parameterString != nil {
        parameterString! += "&\(categoryParameterString)"
      } else {
        parameterString = categoryParameterString
      }
    }
    
    if let startDateParameterString = startDateParameterString {
      if parameterString != nil {
        parameterString! += "&\(startDateParameterString)"
      } else {
        parameterString = startDateParameterString
      }
    }
    
    if let endDateParameterString = endDateParameterString {
      if parameterString != nil {
        parameterString! += "&\(endDateParameterString)"
      } else {
        parameterString = endDateParameterString
      }
    }
    
    if let pageParameterString = pageParameterString {
      if parameterString != nil {
        parameterString! += "&\(pageParameterString)"
      } else {
        parameterString = pageParameterString
      }
    }
    
    let endpoint = ExpenseEndpoint
    let method = "GET"
    let requestDescription = "getExpenses"
    
    makeAPICallToEndpoint(endpoint, method: method, parameterString: parameterString, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let expenseDictionaryArray = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! Array<[String: AnyObject]>
        var expenseArray = [BKExpense]()
        
        for expense in expenseDictionaryArray {
          if let bkExpense = BKExpense(expenseDictionary: expense) {
            expenseArray.append(bkExpense)
          }
        }
        completion(true, expenseArray)
      } else {
        completion(false, nil)
      }
    }
  }
  
  func getAmounts(forUserID userID: String? = nil,
                            categoryID: String? = nil,
                            startDate: Date? = nil,
                            endDate: Date? = nil,
                            requestDescription: String,
                            completion: @escaping BKGetAmountsCompletionBlock) {
    
    var parameterString: String?
    
    var userParameterString: String?
    var categoryParameterString: String?
    var startDateParameterString: String?
    var endDateParameterString: String?
    
    if let userID = userID {
      userParameterString = "user_id=\(userID)"
    }
    
    if let categoryID = categoryID {
      categoryParameterString = "category_id=\(categoryID)"
    }
    
    if let startDate = startDate {
      let startDateString = BKUtilities.dateString(from: startDate)
      startDateParameterString = "start_date=\(startDateString)"
    }
    
    if let endDate = endDate {
      let endDateString = BKUtilities.dateString(from: endDate)
      endDateParameterString = "end_date=\(endDateString)"
    }
    
    if let userParameterString = userParameterString {
      parameterString = userParameterString
    }
    
    if let categoryParameterString = categoryParameterString {
      if parameterString != nil {
        parameterString! += "&\(categoryParameterString)"
      } else {
        parameterString = categoryParameterString
      }
    }
    
    if let startDateParameterString = startDateParameterString {
      if parameterString != nil {
        parameterString! += "&\(startDateParameterString)"
      } else {
        parameterString = startDateParameterString
      }
    }
    
    if let endDateParameterString = endDateParameterString {
      if parameterString != nil {
        parameterString! += "&\(endDateParameterString)"
      } else {
        parameterString = endDateParameterString
      }
    }
    
    let endpoint = AmountEndpoint
    let method = "GET"
    
    makeAPICallToEndpoint(endpoint, method: method, parameterString: parameterString, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
     
      if success {
        
        let amountDictionaryArray = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! Array<[String: AnyObject]>
        var amountArray = [BKAmount]()
        
        for amount in amountDictionaryArray {
          if let bkAmount = BKAmount(amountDictionary: amount) {
            amountArray.append(bkAmount)
          }
        }
        completion(true, amountArray)
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func getAmountsByCategory(forUserID userID: String?, startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: userID, categoryID: "all", startDate: startDate, endDate: endDate, requestDescription: "getAmountsByCategory") { (success, amountArray) in
        completion(success, amountArray)
    }
  }
  
  public func getAmountsByUser(forCategoryID categoryID: String?, startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: "all", categoryID: categoryID, startDate: startDate, endDate: endDate, requestDescription: "getAmountsByUserID") { (success, amountArray) in
      completion(success, amountArray)
    }
  }
  
  public func getAmountsByCategoryAndUser(forStartDate startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: "all", categoryID: "all", startDate: startDate, endDate: endDate, requestDescription: "getAmountsByCategoryAndUser") { (success, amountArray) in
      completion(success, amountArray)
    }
  }
  
  public func getAmount(forUserID userID: String?, categoryID: String?, startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: userID, categoryID: categoryID, startDate: startDate, endDate: endDate, requestDescription: "getAmount") { (success, amountArray) in
      completion(success, amountArray)
    }
  }
  
  public func signIn(withName name: String, password: String, completion: @escaping BKGroupCompletionBlock) {
    
    let endpoint = SignInEndpoint
    let method = "GET"
    let requestDescription = "signIn"
    let customAuthorizationHeader = BKUtilities.authorizationHeader(fromUsername: name, andPassword: password)
    
    makeAPICallToEndpoint(endpoint, method: method, requestDescription: requestDescription, customAuthorizationHeader: customAuthorizationHeader) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        var groupDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        groupDictionary["password"] = password as AnyObject
        
        if let bkGroup = BKGroup.createOrUpdate(with: groupDictionary) {
          completion(true, nil, bkGroup)
        } else {
          completion(false, "An unexpected error occurred. Error code: \(BKAPIErrorType.clientProcessing)", nil)
        }
        
      } else {
        
        if let customErrorMessage = customErrorMessage {
          completion(false, customErrorMessage, nil)
        } else {
          
          let errorType = apiErrorType ?? .unknown
          
          if (errorType == .unauthorized) {
            completion(false, "The household name or password you entered is incorrect.", nil)
          } else {
            completion(false, "A server error occurred. Error code: \(BKAPIErrorType.clientProcessing)", nil)
          }
        }
      }
    }
  }
  
  public func createGroup(withName name: String, password: String, completion: @escaping BKGroupCompletionBlock) {
    
    let bodyString = "name=\(name)&password=\(password)"
    
    let endpoint = GroupEndpoint
    let method = "POST"
    let requestDescription = "createGroup"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        var groupDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        groupDictionary["password"] = password as AnyObject
        
        if let bkGroup = BKGroup.createOrUpdate(with: groupDictionary) {
          completion(true, nil, bkGroup)
        } else {
          completion(false, "An unexpected error occurred. Error code: \(BKAPIErrorType.clientProcessing)", nil)
        }
        
      } else {
        
        if let customErrorMessage = customErrorMessage {
          completion(false, customErrorMessage, nil)
        } else {
          
          let errorType = apiErrorType ?? .unknown
          completion(false, "A server error occurred. Error code: \(errorType)", nil)
        }
      }
    }
  }
  
  public func createUser(withName name: String, completion: @escaping BKCreateUserCompletionBlock) {
    
    let bodyString = "name=\(name)"
    
    let endpoint = UserEndpoint
    let method = "POST"
    let requestDescription = "createUser"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let userDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        
        if let bkUser = BKUser.createOrUpdate(with: userDictionary) {
          completion(true, bkUser)
        } else {
          completion(false, nil)
        }
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func createCategory(withName name: String, color: UIColor, monthlyBudget: Float?, description: String?, completion: @escaping BKCreateCategoryCompletionBlock) {
    
    var bodyString = "name=\(name)&color=\(color.hexString)"
    
    if let monthlyBudget = monthlyBudget {
      bodyString = bodyString + "&monthly_budget=\(monthlyBudget)"
    }
    
    if let description = description {
      bodyString = bodyString + "&description=\(description)"
    }
    
    let endpoint = CategoryEndpoint
    let method = "POST"
    let requestDescription = "createCategory"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let categoryDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        
        if let bkCategory = BKCategory.createOrUpdate(with: categoryDictionary) {
          completion(true, bkCategory)
        } else {
          completion(false, nil)
        }
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func createExpense(withName name: String, amount: Float, userID: String, categoryID: String?, date: Date?, completion: @escaping BKCreateExpenseCompletionBlock) {
    
    var bodyString = "name=\(name)&amount=\(amount)&user_id=\(userID)"
    
    if let categoryID = categoryID {
      bodyString = bodyString + "&category_id=\(categoryID)"
    }
    
    var dateString: String
    
    if let date = date {
      dateString = BKUtilities.dateString(from: date)
    } else {
      dateString = BKUtilities.dateString(from: Date())
    }
    
    bodyString = bodyString + "&date=\(dateString)"
    
    let endpoint = ExpenseEndpoint
    let method = "POST"
    let requestDescription = "createExpense"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let expenseDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        
        if let bkExpense = BKExpense(expenseDictionary: expenseDictionary) {
          completion(true, bkExpense)
        } else {
          completion(false, nil)
        }
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func delete(category: BKCategory, completion: @escaping BKDeleteCompletionBlock) {
    
    let endpoint = CategoryEndpoint + "/\(category.cloudID)"
    let method = "DELETE"
    let requestDescription = "deleteCategory"
    
    makeAPICallToEndpoint(endpoint, method: method, body: nil, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      if success {
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  public func update(category: BKCategory, name: String? = nil, color: UIColor? = nil, monthlyBudget: Float? = nil, description: String? = nil, completion: @escaping BKCreateCategoryCompletionBlock) {
    
    var bodyString = ""
    
    if let name = name {
      bodyString = "name=\(name)"
    }
    
    if let color = color {
      if bodyString.isEmpty {
        bodyString = "color=\(color.hexString)"
      } else {
        bodyString = bodyString + "&color=\(color.hexString)"
      }
    }
    
    if let monthlyBudget = monthlyBudget {
      if bodyString.isEmpty {
        bodyString = "monthlyBudget=\(monthlyBudget)"
      } else {
        bodyString = bodyString + "&monthlyBudget=\(monthlyBudget)"
      }
    }
    
    if let description = description {
      if bodyString.isEmpty {
        bodyString = "description=\(description)"
      } else {
        bodyString = bodyString + "&description=\(description)"
      }
    }
    
    let endpoint = CategoryEndpoint + "/\(category.cloudID)"
    let method = "PATCH"
    let requestDescription = "updateCategory"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let categoryDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        
        if let bkCategory = BKCategory.createOrUpdate(with: categoryDictionary) {
          completion(true, bkCategory)
        } else {
          completion(false, nil)
        }
        
      } else {
        completion(false, nil)
      }
    }
  }
}

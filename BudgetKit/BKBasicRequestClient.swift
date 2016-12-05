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
    
    let endpoint = CategoriesEndpoint
    let method = "GET"
    let requestDescription = "getCategories"
    
    makeAPICallToEndpoint(endpoint, method: method, requestDescription: requestDescription) { (success, response, responseData) -> () in
      
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
    
    let endpoint = UsersEndpoint
    let method = "GET"
    let requestDescription = "getUsers"
    
    makeAPICallToEndpoint(endpoint, method: method, requestDescription: requestDescription) { (success, response, responseData) -> () in
      
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
  
  public func getExpenses(forUserID userID: Int64? = nil,
                                    categoryID: Int64? = nil,
                                    startDate: Date? = nil,
                                    endDate: Date? = nil,
                                    completion: @escaping BKGetExpensesCompletionBlock) {
    
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
    
    let endpoint = ExpensesEndpoint
    let method = "GET"
    let requestDescription = "getExpenses"
    
    makeAPICallToEndpoint(endpoint, method: method, parameterString: parameterString, requestDescription: requestDescription) { (success, response, responseData) in
      
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
  
  func getAmounts(forUserID userID: Int64? = nil,
                            categoryID: Int64? = nil,
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
      if userID == 0 {
        userParameterString = "user_id=all"
      } else {
        userParameterString = "user_id=\(userID)"
      }
    }
    
    if let categoryID = categoryID {
      if categoryID == 0 {
        categoryParameterString = "category_id=all"
      } else {
        categoryParameterString = "category_id=\(categoryID)"
      }
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
    
    makeAPICallToEndpoint(endpoint, method: method, parameterString: parameterString, requestDescription: requestDescription) { (success, response, responseData) in
     
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
  
  public func getAmountsByCategory(forUserID userID: Int64?, startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: userID, categoryID: 0, startDate: startDate, endDate: endDate, requestDescription: "getAmountsByCategory") { (success, amountArray) in
        completion(success, amountArray)
    }
  }
  
  public func getAmountsByUser(forCategoryID categoryID: Int64?, startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: 0, categoryID: categoryID, startDate: startDate, endDate: endDate, requestDescription: "getAmountsByUserID") { (success, amountArray) in
      completion(success, amountArray)
    }
  }
  
  public func getAmountsByCategoryAndUser(forStartDate startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: 0, categoryID: 0, startDate: startDate, endDate: endDate, requestDescription: "getAmountsByCategoryAndUser") { (success, amountArray) in
      completion(success, amountArray)
    }
  }
  
  public func getAmount(forUserID userID: Int64?, categoryID: Int64?, startDate: Date?, endDate: Date?, completion: @escaping BKGetAmountsCompletionBlock) {
    
    self.getAmounts(forUserID: userID, categoryID: categoryID, startDate: startDate, endDate: endDate, requestDescription: "getAmount") { (success, amountArray) in
      completion(success, amountArray)
    }
  }
  
  public func createUser(withName name: String, completion: @escaping BKCreateUserCompletionBlock) {
    
    let bodyString = "name=\(name)"
    
    let endpoint = UsersEndpoint
    let method = "POST"
    let requestDescription = "createUser"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData) in
      
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
  
  public func createCategory(withName name: String, monthlyBudget: Float?, description: String?, completion: @escaping BKCreateCategoryCompletionBlock) {
    
    var bodyString = "name=\(name)"
    
    if let monthlyBudget = monthlyBudget {
      bodyString = bodyString + "&monthly_budget=\(monthlyBudget)"
    }
    
    if let description = description {
      bodyString = bodyString + "&description=\(description)"
    }
    
    let endpoint = CategoriesEndpoint
    let method = "POST"
    let requestDescription = "createCategory"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData) in
      
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
  
  public func createExpense(withName name: String, amount: Float, userID: Int64, categoryID: Int64?, date: Date?, completion: @escaping BKCreateExpenseCompletionBlock) {
    
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
    
    let endpoint = ExpensesEndpoint
    let method = "POST"
    let requestDescription = "createExpense"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData) in
      
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
}

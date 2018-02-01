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
        
        // delete any categories that didn't come back from cloud - they have been deleted from another device
        if let existingCategories = BKCategory.fetchCategories() {
          for category in existingCategories {
            
            let categoryHasBeenDeleted = !categoryDictionaryArray.contains(where: { (categoryDictionary) -> Bool in
              if let cloudID = categoryDictionary["_id"] as? String {
                return cloudID == category.cloudID
              }
              return false
            })
            
            if categoryHasBeenDeleted {
              BKCategory.deleteCategory(withCloudID: category.cloudID)
            }
          }
        }
        
        for categoryDictionary in categoryDictionaryArray {
          if let bkCategory = BKCategory.createOrUpdate(with: categoryDictionary) {
            categoryArray.append(bkCategory)
          }
        }
        
        BKSharedDataController.saveContext()
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
        
        // delete any users that didn't come back from cloud - they have been deleted from another device
        if let existingUsers = BKUser.fetchUsers() {
          for user in existingUsers {
            
            let userHasBeenDeleted = !userDictionaryArray.contains(where: { (userDictionary) -> Bool in
              if let cloudID = userDictionary["_id"] as? String {
                return cloudID == user.cloudID
              }
              return false
            })
            
            if userHasBeenDeleted {
              BKUser.deleteUser(withCloudID: user.cloudID)
            }
          }
        }
        
        for userDictionary in userDictionaryArray {
          if let bkUser = BKUser.createOrUpdate(with: userDictionary) {
            userArray.append(bkUser)
          }
        }
        
        BKSharedDataController.saveContext()
        completion(true, userArray)
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func getAllRecentExpenses(completion: @escaping BKGetExpensesCompletionBlock) {
    
    var parameterString: String?
    
    if let startDate = BKUtilities.dateOfLastExpenseFetch() {
      let startDateString = BKUtilities.dateString(from: startDate)
      parameterString = "updated_since=\(startDateString)"
    }
    
    let endpoint = ExpenseEndpoint
    let method = "GET"
    let requestDescription = "fetchRecentExpenses"
    
    makeAPICallToEndpoint(endpoint, method: method, parameterString: parameterString, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let expenseDictionaryArray = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! Array<[String: AnyObject]>
        var expenseArray = [BKExpense]()
        
        for expenseDictionary in expenseDictionaryArray {
          if let bkExpense = BKExpense.createOrUpdate(with: expenseDictionary) {
            expenseArray.append(bkExpense)
          }
        }
        
        // only update the date of last expense fetch if we're sure that all the expenses up until now have been saved
        if BKSharedDataController.saveContext() {
          BKUtilities.setDateOfLastExpenseFetch(Date())
        }
        
        completion(true, expenseArray)
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
        
        for expenseDictionary in expenseDictionaryArray {
          if let bkExpense = BKExpense.createOrUpdate(with: expenseDictionary) {
            expenseArray.append(bkExpense)
          }
        }
        
        BKSharedDataController.saveContext()
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
        
        // now iterate through categories to check if amountArray is missing any. If so, add them with amount 0
        if let categories = BKCategory.fetchCategories() {
          for category in categories {
            if !amountArray.contains(where: { $0.categoryID == category.cloudID}) {
               let emptyAmount = BKAmount(withAmount: 0, categoryID: category.cloudID, userID: userID, startDate: startDate, endDate: endDate)
              amountArray.append(emptyAmount)
            }
          }
        }
        
        // finally, sort amount array so that amounts are always displayed in a consistent order
        amountArray.sort {
          if $0.categoryID == nil {
            return false
          } else if $1.categoryID == nil {
            return true
          } else {
            return $0.categoryID! < $1.categoryID!
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
          
          // once we have signed in successfully, do an initial fetch of users, categories and expenses
          BKSharedBasicRequestClient.getUsers(completion: { (success, userArray) in
            
            guard success else {
              completion(false, "A server error occurred. Error code: \(BKAPIErrorType.clientProcessing)", nil)
              return
            }
            
            BKSharedBasicRequestClient.getCategories { (success, categoryArray) in
              
              guard success else {
                completion(false, "A server error occurred. Error code: \(BKAPIErrorType.clientProcessing)", nil)
                return
              }
              
              BKSharedBasicRequestClient.getAllRecentExpenses { (success, expenseArray) in
                
                guard success else {
                  completion(false, "A server error occurred. Error code: \(BKAPIErrorType.clientProcessing)", nil)
                  return
                }
                
                completion(true, nil, bkGroup)
              }
            }
          })
          
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
          BKSharedDataController.saveContext()
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
          BKSharedDataController.saveContext()
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
      bodyString = bodyString + "&monthlyBudget=\(monthlyBudget)"
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
          BKSharedDataController.saveContext()
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
        
        if let bkExpense = BKExpense.createOrUpdate(with: expenseDictionary) {
          BKSharedDataController.saveContext()
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
        BKCategory.deleteCategory(withCloudID: category.cloudID)
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  public func delete(user: BKUser, completion: @escaping BKDeleteCompletionBlock) {
    
    let endpoint = UserEndpoint + "/\(user.cloudID)"
    let method = "DELETE"
    let requestDescription = "deleteUser"
    
    makeAPICallToEndpoint(endpoint, method: method, body: nil, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      if success {
        BKUser.deleteUser(withCloudID: user.cloudID)
        completion(true)
      } else {
        completion(false)
      }
    }
  }
  
  public func delete(expense: BKExpense, completion: @escaping BKDeleteCompletionBlock) {
    
    let endpoint = ExpenseEndpoint + "/\(expense.cloudID)"
    let method = "DELETE"
    let requestDescription = "deleteExpense"
    
    makeAPICallToEndpoint(endpoint, method: method, body: nil, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      if success {
        BKExpense.deleteExpense(withCloudID: expense.cloudID)
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
          BKSharedDataController.saveContext()
          completion(true, bkCategory)
        } else {
          completion(false, nil)
        }
        
      } else {
        completion(false, nil)
      }
    }
  }
  
  public func updateExpense(expense: BKExpense, name: String? = nil, amount: Float? = nil, userID: String? = nil, categoryID: String? = nil, date: Date? = nil, completion: @escaping BKCreateExpenseCompletionBlock) {
    
    var bodyString = ""
    
    if let name = name {
      bodyString = "name=\(name)"
    }
    
    if let amount = amount {
      if bodyString.isEmpty {
        bodyString = "amount=\(amount)"
      } else {
        bodyString = bodyString + "&amount=\(amount)"
      }
    }
    
    if let userID = userID {
      if bodyString.isEmpty {
        bodyString = "user_id=\(userID)"
      } else {
        bodyString = bodyString + "&user_id=\(userID)"
      }
    }
    
    if let categoryID = categoryID {
      if bodyString.isEmpty {
        bodyString = "category_id=\(categoryID)"
      } else {
        bodyString = bodyString + "&category_id=\(categoryID)"
      }
    }
    
    if let date = date {
      let dateString = BKUtilities.dateString(from: date)
      if bodyString.isEmpty {
        bodyString = "date=\(dateString)"
      } else {
        bodyString = bodyString + "&date=\(dateString)"
      }
    }
    
    let endpoint = ExpenseEndpoint + "/\(expense.cloudID)"
    let method = "PATCH"
    let requestDescription = "updateExpense"
    let body = bodyString.data(using: String.Encoding.utf8)
    
    makeAPICallToEndpoint(endpoint, method: method, body: body, requestDescription: requestDescription) { (success, response, responseData, apiErrorType, customErrorMessage) in
      
      if success {
        
        let expenseDictionary = (try! JSONSerialization.jsonObject(with: responseData!, options: [])) as! [String: AnyObject]
        
        if let bkExpense = BKExpense.createOrUpdate(with: expenseDictionary) {
          BKSharedDataController.saveContext()
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

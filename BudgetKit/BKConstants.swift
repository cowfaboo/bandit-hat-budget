//
//  BKConstants.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

let APIPrefix = "https://bandit-hat-budget.herokuapp.com"

let CategoriesEndpoint = APIPrefix + "/categories"
let UsersEndpoint = APIPrefix + "/users"
let ExpensesEndpoint = APIPrefix + "/expenses"
let AmountEndpoint = ExpensesEndpoint + "/amount"

public typealias BKGetUsersCompletionBlock = (Bool, Array<BKUser>?) -> ()

public let BKSharedBasicRequestClient = BKBasicRequestClient.sharedInstance

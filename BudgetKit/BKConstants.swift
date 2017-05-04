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
public typealias BKGetCategoriesCompletionBlock = (Bool, Array<BKCategory>?) -> ()
public typealias BKGetExpensesCompletionBlock = (Bool, Array<BKExpense>?) -> ()
public typealias BKGetAmountsCompletionBlock = (Bool, Array<BKAmount>?) -> ()
public typealias BKGetAmountCompletionBlock = (Bool, BKAmount?) -> ()
public typealias BKCreateUserCompletionBlock = (Bool, BKUser?) -> ()
public typealias BKCreateCategoryCompletionBlock = (Bool, BKCategory?) -> ()
public typealias BKCreateExpenseCompletionBlock = (Bool, BKExpense?) -> ()
public typealias BKDeleteCompletionBlock = (Bool) -> ()

public let BKSharedDataController = BKDataController.sharedInstance
public let BKSharedBasicRequestClient = BKBasicRequestClient.sharedInstance

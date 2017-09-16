//
//  BKConstants.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-11-24.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation

let APIPrefix = "https://boiling-bastion-50971.herokuapp.com"

let CategoryEndpoint = APIPrefix + "/category"
let UserEndpoint = APIPrefix + "/user"
let GroupEndpoint = APIPrefix + "/group"
let ExpenseEndpoint = APIPrefix + "/expense"
let AmountEndpoint = ExpenseEndpoint + "/amount"
let SignInEndpoint = GroupEndpoint + "/signin"

public typealias BKGetUsersCompletionBlock = (Bool, Array<BKUser>?) -> ()
public typealias BKGetCategoriesCompletionBlock = (Bool, Array<BKCategory>?) -> ()
public typealias BKGetExpensesCompletionBlock = (Bool, Array<BKExpense>?) -> ()
public typealias BKGetAmountsCompletionBlock = (Bool, Array<BKAmount>?) -> ()
public typealias BKGetAmountCompletionBlock = (Bool, BKAmount?) -> ()
public typealias BKCreateUserCompletionBlock = (Bool, BKUser?) -> ()
public typealias BKGroupCompletionBlock = (Bool, String?, BKGroup?) -> ()
public typealias BKCreateCategoryCompletionBlock = (Bool, BKCategory?) -> ()
public typealias BKCreateExpenseCompletionBlock = (Bool, BKExpense?) -> ()
public typealias BKDeleteCompletionBlock = (Bool) -> ()

public let BKSharedDataController = BKDataController.sharedInstance
public let BKSharedBasicRequestClient = BKBasicRequestClient.sharedInstance

//
//  BKExpense+CoreDataProperties.swift
//  BudgetKit
//
//  Created by Daniel Gauthier on 2018-04-26.
//  Copyright © 2018 Bandit Hat Apps. All rights reserved.
//
//

import Foundation
import CoreData


extension BKExpense {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BKExpense> {
        return NSFetchRequest<BKExpense>(entityName: "BKExpense")
    }

    @NSManaged public var amount: Float
    @NSManaged public var cloudID: String
    @NSManaged public var date: NSDate
    @NSManaged public var dateCreated: NSDate
    @NSManaged public var dateUpdated: NSDate
    @NSManaged public var name: String
    @NSManaged public var category: BKCategory?
    @NSManaged public var user: BKUser?

}

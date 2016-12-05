//
//  BKCategory+CoreDataProperties.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-03.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BKCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BKCategory> {
        return NSFetchRequest<BKCategory>(entityName: "BKCategory");
    }

    @NSManaged public var cloudID: Int64
    @NSManaged public var name: String
    @NSManaged public var details: String?
    @NSManaged public var monthlyBudget: Float
    @NSManaged public var dateCreated: NSDate
    @NSManaged public var dateUpdated: NSDate

}

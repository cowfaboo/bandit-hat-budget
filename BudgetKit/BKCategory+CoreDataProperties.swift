//
//  BKCategory+CoreDataProperties.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-12.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//

import Foundation
import CoreData


extension BKCategory {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BKCategory> {
        return NSFetchRequest<BKCategory>(entityName: "BKCategory");
    }

    @NSManaged public var cloudID: Int64
    @NSManaged var dateCreated: NSDate?
    @NSManaged var dateUpdated: NSDate?
    @NSManaged public var details: String?
    @NSManaged public var monthlyBudget: Float
    @NSManaged public var name: String
    @NSManaged var colorString: String

}

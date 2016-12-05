//
//  BKUser+CoreDataProperties.swift
//  Budget
//
//  Created by Daniel Gauthier on 2016-12-03.
//  Copyright © 2016 Bandit Hat Apps. All rights reserved.
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension BKUser {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BKUser> {
        return NSFetchRequest<BKUser>(entityName: "BKUser");
    }

    @NSManaged public var cloudID: Int64
    @NSManaged public var name: String?
    @NSManaged public var dateCreated: NSDate
    @NSManaged public var dateUpdated: NSDate

}

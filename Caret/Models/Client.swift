//
//  Client.swift
//  Caret
//
//  Created by Nate Armstrong on 4/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import CoreData

class Client: NSManagedObject {

    @NSManaged var apiID: NSNumber?
    @NSManaged var archived: NSNumber
    @NSManaged var guid: String
    @NSManaged var hourly_rate: NSNumber
    @NSManaged var name: String
    @NSManaged var sync_status: NSNumber
    @NSManaged var updated_at: NSDate?
    @NSManaged var projects: NSSet

}

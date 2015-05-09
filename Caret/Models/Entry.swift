//
//  Entry.swift
//  Caret
//
//  Created by Nate Armstrong on 4/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import CoreData

class Entry: NSManagedObject {

    @NSManaged var updated_at: NSDate?
    @NSManaged var happened_on: NSDate
    @NSManaged var archived: NSNumber
    @NSManaged var duration: NSNumber
    @NSManaged var guid: String
    @NSManaged var apiID: NSNumber?
    @NSManaged var notes: String
    @NSManaged var sync_status: NSNumber
    @NSManaged var project: Project?

}

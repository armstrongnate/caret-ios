//
//  Client.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import CoreData

class ClientEntity: NSManagedObject {

  @NSManaged var name: String
  @NSManaged var hourly_rate: NSNumber
  @NSManaged var sync_status: NSNumber
  @NSManaged var updated_at: NSDate?
  @NSManaged var archived: NSNumber
  @NSManaged var guid: String

}

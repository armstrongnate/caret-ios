//
//  ClientTestCase.swift
//  Caret
//
//  Created by Nate Armstrong on 4/17/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class ClientTestCase: CoreDataTestCase {

  var client: Client?

  override func setUp() {
    super.setUp()
    let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: managedObjectContext!)
    client = Client(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
    XCTAssertNotNil(client, "client is not nil")
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testRequiredAttributes() {
    if let client = client, context = managedObjectContext {
      client.name = "Nate"
      var error: NSError?
      XCTAssert(!context.save(&error), "client not saved")

      client.hourly_rate = 85
      client.archived = false
      client.sync_status = 0
      client.guid = "test"
      var error2: NSError?
      XCTAssert(context.save(&error2), "client saved")
    }
  }

  func testSyncStatus() {
    if let client = client, context =  managedObjectContext {
      client.syncStatus = .NoChanges
      XCTAssertEqual(client.sync_status, 0, "no changes syncStatus is 0")
      client.syncStatus = .Changed
      XCTAssertEqual(client.sync_status, 1, "changed syncStatus is 1")
      client.syncStatus = .Temporary
      XCTAssertEqual(client.sync_status, 2, "temporary syncStatus is 2")
    }
  }

  func testToJSON() {
    if let client = client {
      client.name = "My Client"
      client.hourly_rate = 85
      client.guid = "abc123"
      client.apiID = 10
      var json = client.toJSON()
      XCTAssertEqual(json["name"] as! String, "My Client", "name matches")
      XCTAssertEqual(json["hourly_rate"] as! NSNumber, 85, "hourly_rate matches")
      XCTAssertEqual(json["guid"] as! String, "abc123", "guid matches")
      XCTAssertEqual(json["id"] as! NSNumber, 10, "id matches")

      client.apiID = nil
      json = client.toJSON()
      XCTAssertEqual(json["id"] as! String, "", "id can be blank")
    }
  }

  func testFromJSON() {
    if let client = client {
      let updated_at = "2015-04-16 22:24:17 -0600"
      let json: [String: AnyObject] = [
        "id": 10,
        "name": "My Client",
        "hourly_rate": 85,
        "guid": "abc123",
        "updated_at": updated_at
      ]
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      client.fromJSON(json, formatter: dateFormatter)
      XCTAssertEqual(client.apiID!, 10, "apiID matches")
      XCTAssertEqual(client.name, "My Client", "name matches")
      XCTAssertEqual(client.hourly_rate, 85, "hourly_rate matches")
      XCTAssertEqual(client.guid, "abc123", "guid matches")
      XCTAssert(client.updated_at!.isEqualToDate(dateFormatter.dateFromString(updated_at)!), "updated_at matches")
      XCTAssertEqual(client.syncStatus, .NoChanges, "sync status matches")
    }
  }

}

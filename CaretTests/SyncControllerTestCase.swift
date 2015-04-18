//
//  SyncControllerTestCase.swift
//  Caret
//
//  Created by Nate Armstrong on 4/17/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class SyncControllerTestCase: CoreDataTestCase {

  var syncController: SyncController?

  override func setUp() {
    super.setUp()
    syncController = SyncController(context: managedObjectContext!)
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testFindOrInitializeClassFinds() {
    // create new client
    XCTAssertNotNil(syncController, "syncController is not nil")
    if let syncController = syncController {
      let client = insertClient()
      client.name = "My Client"
      client.hourly_rate = 85
      client.archived = false
      client.sync_status = 0
      client.guid = "test"
      var createError: NSError?
      syncController.context.save(&createError)

      // find created client
      let foundClient = syncController.findOrInitializeClass("Client", guid: "test")
      XCTAssertNotNil(foundClient, "client is not nil")
      let saved = !foundClient!.objectID.temporaryID
      XCTAssert(saved, "found is not a new record")
    }
  }

  func testFindOrInitializeClassInitializes() {
    let client = syncController?.findOrInitializeClass("Client", guid: "test2")
    XCTAssertNotNil(client, "client is not nil")
    let saved = !client!.objectID.temporaryID
    XCTAssert(!saved, "client is a new record")
  }

  func testMostRecentUpdatedAtDateForClass() {
    // should return nil for an empty dataset
    XCTAssertNil(syncController!.mostRecentUpdatedAtDateForClass("Client"), "most recent is nil")

    let now = NSDate()
    var client = insertClient()
    client.updated_at = now

    let epoch = NSDate(timeIntervalSince1970: 0)
    client = insertClient()
    client.updated_at = epoch

    var error: NSError?
    managedObjectContext!.save(&error)

    let date = syncController!.mostRecentUpdatedAtDateForClass("Client")
    XCTAssertNotNil(date, "most recent is set")
    XCTAssert(date!.isEqualToDate(now), "most recent matches")

    let future = now.dateByAddingTimeInterval(1000)
    client = insertClient()
    client.updated_at = future

    let date2 = syncController!.mostRecentUpdatedAtDateForClass("Client")
    XCTAssertNotNil(date2, "most recent is set")
    XCTAssert(date2!.isEqualToDate(future), "most recent matches")
  }

  func testManagedObjectsForClassWithSyncStatus() {
    let none = syncController!.managedObjectsForClass("Client", withSyncStatus: .Changed)
    XCTAssertEqual(none.count, 0, "changed count is zero")

    let client = insertClient()
    client.syncStatus = .Changed
    var error: NSError?
    XCTAssert(managedObjectContext!.save(&error), "client saves")

    let clients = syncController!.managedObjectsForClass("Client", withSyncStatus: .Changed)
    XCTAssertEqual(clients.count, 1, "changed count is 1")
  }

  private func insertClient() -> Client {
    let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: managedObjectContext!)
    let client = Client(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
    client.name = "My Client"
    client.hourly_rate = 85
    client.archived = false
    client.sync_status = 0
    client.guid = NSUUID().UUIDString
    client.updated_at = nil
    return client
  }

}

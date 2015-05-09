//
//  ProjectTestCase.swift
//  Caret
//
//  Created by Nate Armstrong on 4/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class ProjectTestCase: CoreDataTestCase {

  var project: Project?

  override func setUp() {
    super.setUp()
    let entity = NSEntityDescription.entityForName("Project", inManagedObjectContext: managedObjectContext!)
    project = Project(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
    XCTAssertNotNil(project, "project is not nil")
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testToJSON() {
    XCTAssertNotNil(project, "project is not nil")
    if let project = project {
      let client = insertClient()
      project.name = "My Project"
      project.hourly_rate = 85
      project.guid = "123abc"
      project.apiID = 10
      project.client = client
      let json = project.toJSON(NSDateFormatter())
      XCTAssertEqual(json["name"] as! String, "My Project", "name matches")
      XCTAssertEqual(json["hourly_rate"] as! NSNumber, 85, "hourly_rate matches")
      XCTAssertEqual(json["guid"] as! String, "123abc", "guid matches")
      XCTAssertEqual(json["id"] as! NSNumber, 10, "id matches")
      XCTAssertEqual(json["client_id"] as! NSNumber, 1, "client id matches")
    }

  }

  func testFromJSON() {
    XCTAssertNotNil(project, "project is not nil")
    if let project = project {
      let client = insertClient()
      let client2 = insertClient()
      client2.apiID = 2
      client2.name = "My Client 2"
      let updated_at = "2015-04-16 22:24:17 -0600"
      let json: [String: AnyObject] = [
        "id": 10,
        "name": "My Project",
        "hourly_rate": 85,
        "guid": "abc123",
        "updated_at": updated_at,
        "client_id": client.apiID!
      ]
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      project.fromJSON(json, formatter: dateFormatter, context: managedObjectContext!)
      XCTAssertNotNil(project.client, "project client is not nil")
      XCTAssertEqual(project.client!.name, "My Client", "project client name matches")
      XCTAssertEqual(project.apiID!, 10, "id matches")
      XCTAssertEqual(project.name, "My Project", "name matches")
      XCTAssertEqual(project.hourly_rate, 85, "hourly rate matches")
      XCTAssertEqual(project.guid, "abc123", "guid matches")
      XCTAssert(project.updated_at!.isEqualToDate(dateFormatter.dateFromString(updated_at)!), "updated_at matches")
      XCTAssertEqual(project.syncStatus, .NoChanges, "sync status matches")
    }
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
    client.apiID = 1
    return client
  }

}

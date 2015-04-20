//
//  EntryTestCase.swift
//  Caret
//
//  Created by Nate Armstrong on 4/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class EntryTestCase: CoreDataTestCase {

  var entry: Entry?

  override func setUp() {
    super.setUp()
    let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: managedObjectContext!)
    entry = Entry(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
    XCTAssertNotNil(entry, "entry is not nil")
  }

  override func tearDown() {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    super.tearDown()
  }

  func testToJSON() {
    XCTAssertNotNil(entry, "entry is not nil")
    if let entry = entry {
      let project = insertProject()
      entry.notes = "Worked on something."
      entry.duration = 60
      entry.guid = "123abc"
      entry.project = project
      entry.happened_on = NSDate()
      entry.apiID = nil
      entry.archived = true
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      var json = entry.toJSON(dateFormatter)
      XCTAssertNil(json["id"], "id is nil")
      XCTAssertEqual(json["description"] as! String, "Worked on something.", "notes matches")
      XCTAssertEqual(json["duration"] as! NSNumber, 60, "duration matches")
      XCTAssertEqual(json["guid"] as! String, "123abc", "guid matches")
      XCTAssertEqual(json["project_id"] as! NSNumber, 1, "project id matches")
      XCTAssert(json["deleted"] as! Bool, "entry is deleted")
      XCTAssertNotNil(json["happened_on"] as! String, "happened_on not nil")
      entry.apiID = 10
      entry.archived = false
      json = entry.toJSON(dateFormatter)
      XCTAssertEqual(json["id"] as! NSNumber, 10, "id matches")
      XCTAssert(!(json["deleted"] as! Bool), "entry is not deleted")
    }

  }

  func testFromJSON() {
    XCTAssertNotNil(entry, "entry is not nil")
    if let entry = entry {
      let project = insertProject()
      let project2 = insertProject()
      project2.apiID = 2
      project2.name = "My Project 2"
      let updated_at = "2015-04-16 22:24:17 -0600"
      let happened_on = "2015-04-16"
      let json: [String: AnyObject] = [
        "id": 10,
        "description": "My notes",
        "duration": 120,
        "guid": "abc123",
        "happened_on": happened_on,
        "updated_at": updated_at,
        "project_id": project.apiID!,
        "deleted": true,
      ]
      let dateFormatter = NSDateFormatter()
      dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
      entry.fromJSON(json, formatter: dateFormatter, context: managedObjectContext!)
      XCTAssertNotNil(entry.project, "entry project is not nil")
      XCTAssertEqual(entry.project.name, "My Project", "entry project name matches")
      XCTAssertEqual(entry.apiID!, 10, "id matches")
      XCTAssertEqual(entry.notes, "My notes", "name matches")
      XCTAssertEqual(entry.duration, 120, "duration matches")
      XCTAssertEqual(entry.guid, "abc123", "guid matches")
      XCTAssert(entry.isArchived, "entry is archived")
      XCTAssertNotNil(entry.happened_on, "happened_on is not nil")
      XCTAssert(entry.updated_at!.isEqualToDate(dateFormatter.dateFromString(updated_at)!), "updated_at matches")
      dateFormatter.dateFormat = "yyyy-MM-dd"
      XCTAssert(entry.happened_on.isEqualToDate(dateFormatter.dateFromString(happened_on)!), "happened_on matches")
      XCTAssertEqual(entry.syncStatus, .NoChanges, "sync status matches")
    }
  }

  private func insertProject() -> Project {
    let entity = NSEntityDescription.entityForName("Project", inManagedObjectContext: managedObjectContext!)
    let project = Project(entity: entity!, insertIntoManagedObjectContext: managedObjectContext!)
    project.name = "My Project"
    project.hourly_rate = 85
    project.archived = false
    project.sync_status = 0
    project.guid = NSUUID().UUIDString
    project.updated_at = nil
    project.apiID = 1
    return project
  }

}

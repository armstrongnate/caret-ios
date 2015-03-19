//
//  CaretAPI.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

let kMyAPIKey = "CLKcJvMU-faDZBBEgC_74Q"

class CaretAPI: NSObject {

  struct Static {
    static var sharedInstance = CaretAPI()
  }

  class var sharedInstance: CaretAPI {
    get { return Static.sharedInstance }
    set { Static.sharedInstance = newValue }
  }

  lazy var entries = Resource<Entry>(name: "entries")
  lazy var projects = Resource<Project>(name: "projects")


  // MARK: - Entries

  func getEntries(start: NSDate, to end: NSDate, completion: Resource<Entry>.CollectionResponse? = nil) {
    let format = "yyyy-MM-dd"
    let byRange = "\(start.stringWithFormat(format))," +
      "\(end.stringWithFormat(format))"

    entries.all(parameters: ["by_range": byRange]) { (entries) in
      Caret.stores.entries.create(entries ?? [])
      completion?(collection: entries)
    }
  }

  func getEntries(date: NSDate, completion: Resource<Entry>.CollectionResponse? = nil) {
    getEntries(date, to: date)
  }

  func getProjects(completion: Resource<Project>.CollectionResponse? = nil) {
    projects.all(parameters: nil) { (projects) in
      Caret.stores.projects.create(projects ?? [])
      completion?(collection: projects)
    }
  }

}

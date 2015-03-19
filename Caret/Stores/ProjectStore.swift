//
//  ProjectStore.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class ProjectStore: EventEmitter {

  var projects: [NSNumber: Project] = [:]

  func emitChange() {
    dispatch_async(dispatch_get_main_queue()) {
      self.emit(.Change)
    }
  }

  func create(projects: [Project]) {
    for project in projects {
      if let id = project.projectID {
        self.projects[id] = project
      }
    }
    emitChange()
  }

  func get(projectID: NSNumber) -> Project? {
    return projects[projectID]
  }

  func clear() {
    projects = [:]
    emitChange()
  }

   
}

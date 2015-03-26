//
//  Project.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

final class Project: NSObject {

  var projectID: NSNumber?
  var clientID: NSNumber?
  var name: String!
  var color: String?


  private override init() {
    super.init()
  }

}

extension Project: ResponseObjectSerializable {

  convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
    self.init()
    projectID = representation.valueForKeyPath("id") as? NSNumber
    clientID = representation.valueForKeyPath("client_id") as? NSNumber
    name = representation.valueForKeyPath("name") as String
    color = representation.valueForKeyPath("color") as? String
  }

  func toJSON() -> [String : AnyObject] {
    return [:]
  }

  func resourceID() -> NSNumber? {
    return projectID
  }

}

extension Project: ResponseCollectionSerializable {

  class func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Project] {
    var projects: [Project] = []
    for dict in representation as NSArray {
      if let project = Project(response: response, representation: dict as NSObject) {
        projects.append(project)
      }
    }
    return projects
  }

}

//
//  EntryHelper.swift
//  Caret
//
//  Created by Nate Armstrong on 4/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Entry {

  override func toJSON() -> JSONObject {
    return [
      "id": apiID ?? "",
      "description": notes,
      "duration": duration,
      "guid": guid,
      "project_id": project.apiID ?? ""
    ]
  }

  override func fromJSON(json: JSONObject, formatter: NSDateFormatter, context: NSManagedObjectContext) {
    let json = JSON(json)
    guid = json["guid"].string!
    apiID = json["id"].number!
    notes = json["description"].string!
    duration = json["duration"].numberValue
    archived = json["archived"].boolValue
    if let updated_at = json["updated_at"].string {
      self.updated_at = formatter.dateFromString(updated_at)
    }

    let dateFormat = formatter.dateFormat
    formatter.dateFormat = "yyyy-MM-dd"
    happened_on = formatter.dateFromString(json["happened_on"].string!)!
    formatter.dateFormat = dateFormat

    let project_id = json["project_id"].numberValue
    if let project = findProject(project_id, inContext: context) {
      self.project = project
    } else {
      println("project not found!")
    }
  }

  private func findProject(id: NSNumber, inContext context: NSManagedObjectContext) -> Project? {
    var project: Project?
    let fetchRequest = NSFetchRequest(entityName: "Project")
    let predicate = NSPredicate(format: "apiID = %@", id)
    fetchRequest.predicate = predicate
    var error: NSError?
    let results = context.executeFetchRequest(fetchRequest, error: &error)
    println("find project results count = \(results?.count)")
    return results?.first as? Project
  }

}

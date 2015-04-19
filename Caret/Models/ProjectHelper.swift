//
//  ProjectHelper.swift
//  Caret
//
//  Created by Nate Armstrong on 4/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import SwiftyJSON
import CoreData

extension Project {

  override func toJSON() -> JSONObject {
    return [
      "id": apiID ?? "",
      "name": name,
      "hourly_rate": hourly_rate,
      "guid": guid,
      "client_id": client.apiID ?? ""
    ]
  }

  override func fromJSON(json: JSONObject, formatter: NSDateFormatter, context: NSManagedObjectContext) {
    let json = JSON(json)
    guid = json["guid"].string!
    apiID = json["id"].number!
    name = json["name"].string!
    hourly_rate = json["hourly_rate"].numberValue
    archived = json["archived"].boolValue
    if let updated_at = json["updated_at"].string {
      self.updated_at = formatter.dateFromString(updated_at)
    }
    let client_id = json["client_id"].numberValue
    if let client = findClient(client_id, inContext: context) {
      self.client = client
    } else {
      println("client not found!")
    }
  }

  private func findClient(id: NSNumber, inContext context: NSManagedObjectContext) -> Client? {
    var client: Client?
    let fetchRequest = NSFetchRequest(entityName: "Client")
    let predicate = NSPredicate(format: "apiID = %@", id)
    fetchRequest.predicate = predicate
    var error: NSError?
    let results = context.executeFetchRequest(fetchRequest, error: &error)
    println("find client results count = \(results?.count)")
    return results?.first as? Client
  }

}

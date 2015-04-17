//
//  SyncController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/16/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData
import Alamofire
import SwiftyJSON

typealias JSONObject = [String: AnyObject]
typealias SyncDictionary = [String: [NSManagedObject]]

class SyncController: NSObject {

  var context: NSManagedObjectContext
  lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter
  }()
  var names = [
    "clients": "Client"
  ]

  init(context: NSManagedObjectContext) {
    self.context = context
  }

  func sync(toSync: SyncDictionary, lastUpdatedAt: String) {
    context.performBlockAndWait {
      var params = JSONObject()
      for (name, objects) in toSync {
        let jsonObjects = objects.map{ $0.toJSON() }
        var params: JSONObject = [name: jsonObjects]
        params["api_key"] = kMyAPIKey
        params["updated_at"] = lastUpdatedAt
        self.post(name, params: params)
      }
    }
  }

  private func post(name: String, params: JSONObject) {
    Alamofire.request(.POST, "\(kApiURL)/\(name)/sync", parameters: params)
      .responseJSON { (_, _, json, error) in
        println("JSON: \(json)")
        if error == nil {
          let j = JSON(json!)
          self.handleResponse(j, name: name)
        }
      }
  }

  // TODO: speed this up by avoiding a query on every incoming record.
  // Maybe do one query with a map of the jsonObjects guids.
  // What's worse, loading a gazillion into memory or performing a gazillion queries? Speed vs resources?
  // I guess we could do it in batches.
  // Of course, it probably won't make much of a difference after the first sync.
  private func handleResponse(response: JSON, name: String) {
    if let objects = response.array {
      for json in objects {
        if let object = findOrInitializeClass(name, guid: json["guid"].string!) {
          if let jsonObject = json.object as? JSONObject {
            println("should convert! YAY!")
            object.fromJSON(jsonObject, formatter: dateFormatter)
          }
        } else {
          println("failed to find or init class \(json)")
        }
      }
      var error: NSError?
      if !context.save(&error) {
        println("error saving sync context \(error)") // TODO: handle error
      }
    } else {
      println("json is not an array \(response)") // TODO: handle error
    }
  }

  private func findOrInitializeClass(name: String, guid: String) -> NSManagedObject? {
    let className = names[name]!
    var object: NSManagedObject? = nil
    let fetchRequest = NSFetchRequest(entityName: className)
    let predicate = NSPredicate(format: "guid = %@", guid)
    fetchRequest.predicate = predicate

    var error: NSError?
    if let results = self.context.executeFetchRequest(fetchRequest, error: &error) {
      if results.count > 1 {
        println("duplicate guid \(guid)") // TODO: handle duplicate
      } else if results.count == 0 {
        object = NSEntityDescription.insertNewObjectForEntityForName(className, inManagedObjectContext: context) as? NSManagedObject
      } else {
        object = results.last as? NSManagedObject
      }
    } else {
      println("nil results \(error)") // TODO: handle error
    }

    return object
  }

}

extension NSManagedObject {

  func toJSON() -> JSONObject {
    fatalError("Method unimplemented")
  }

  func fromJSON(json: JSONObject, formatter: NSDateFormatter) {
    fatalError("Method unimplemented")
  }

}

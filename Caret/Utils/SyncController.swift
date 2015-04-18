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

let kMyAPIKey = "X1-nd1A3tCwswqV5pIVEDA"
let kApiURL = "http://192.168.1.18"

typealias JSONObject = [String: AnyObject]
typealias SyncDictionary = [String: [NSManagedObject]]

protocol SyncControllerDelegate {

  func syncFinished()

}

class SyncController: NSObject {

  enum SyncStatus: NSNumber {
    case NoChanges = 0
    case Changed = 1
    case Temporary = 2
  }

  var context: NSManagedObjectContext
  var delegate: SyncControllerDelegate?
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

  func sync(classes: [String]) {
    var params = JSONObject()
    for name in classes {
      if self.names[name] == nil { continue }
      let objects = self.managedObjectsForClass(self.names[name]!, withSyncStatus: .Changed)
      let jsonObjects = objects.map{ $0.toJSON() }
      var params: JSONObject = [name: jsonObjects]
      params["api_key"] = kMyAPIKey
      let lastUpdate = self.mostRecentUpdatedAtDateForClass(self.names[name]!) ?? NSDate(timeIntervalSince1970: 0)
      params["updated_at"] = lastUpdate
      self.post(name, params: params)
    }
  }

  private func post(name: String, params: JSONObject) {
    Alamofire.request(.POST, "\(kApiURL)/\(name)/sync", parameters: params)
      .responseJSON { (_, _, json, error) in
        if error == nil {
          let j = JSON(json!)
          self.handleResponse(j, name: name)
        } else {
          println("sync error \(error)")
        }
      }
  }

  // TODO: speed this up by avoiding a query on every incoming record.
  // Maybe do one query with a map of the jsonObjects guids.
  // What's worse, loading a gazillion into memory or performing a gazillion queries? Speed vs resources?
  // I guess we could do it in batches.
  // Of course, it probably won't make much of a difference after the first sync.
  private func handleResponse(response: JSON, name: String) {
    context.performBlock {
      if let objects = response.array {
        for json in objects {
          var object: NSManagedObject?
          object = self.findOrInitializeClass(self.names[name]!, guid: json["guid"].string!)
          if let object = object {
            if let jsonObject = json.object as? JSONObject {
              object.fromJSON(jsonObject, formatter: self.dateFormatter)
              object.syncStatus = .NoChanges
            }
          } else {
            println("failed to find or init class \(json)")
          }
        }
        var error: NSError?
        if !self.context.save(&error) {
          println("error saving sync context \(error)") // TODO: handle error
        } else {
          self.delegate?.syncFinished()
          println("success saving sync context")
        }
      } else {
        println("json is not an array \(response)") // TODO: handle error
      }
    }
  }

  func findOrInitializeClass(className: String, guid: String) -> NSManagedObject? {
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

  func mostRecentUpdatedAtDateForClass(className: String) -> NSDate? {
    let fetchRequest = NSFetchRequest(entityName: className)
    fetchRequest.sortDescriptors = [NSSortDescriptor(key: "updated_at", ascending: false)]
    fetchRequest.fetchLimit = 1
    var error: NSError?
    let results = self.context.executeFetchRequest(fetchRequest, error: &error)
    return results?.last?.valueForKey("updated_at") as? NSDate
  }

  func managedObjectsForClass(className: String, withSyncStatus syncStatus: SyncStatus) -> [NSManagedObject] {
    let fetchRequest = NSFetchRequest(entityName: className)
    let predicate = NSPredicate(format: "sync_status = %@", syncStatus.rawValue)
    fetchRequest.predicate = predicate

    var error: NSError?
    return context.executeFetchRequest(fetchRequest, error: &error) as? [NSManagedObject] ?? []
  }

}

extension NSManagedObject {

  var syncStatus: SyncController.SyncStatus {
    get {
      let status = valueForKey("sync_status") as! NSNumber
      return SyncController.SyncStatus(rawValue: status) ?? .Temporary
    }
    set { setValue(newValue.rawValue, forKey: "sync_status") }
  }

  func toJSON() -> JSONObject {
    fatalError("Method unimplemented")
  }

  func fromJSON(json: JSONObject, formatter: NSDateFormatter) {
    fatalError("Method unimplemented")
  }

}

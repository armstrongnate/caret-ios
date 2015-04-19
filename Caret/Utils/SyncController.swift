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

class SyncController: NSObject {

  typealias SyncCallbackBlock = () -> Void

  enum SyncStatus: NSNumber {
    case NoChanges = 0
    case Changed = 1
    case Temporary = 2
  }

  var context: NSManagedObjectContext
  var callback: SyncCallbackBlock?
  var queue = [String]()
  lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss Z"
    return formatter
  }()
  var names = [
    "clients": "Client",
    "projects": "Project"
  ]

  init(context: NSManagedObjectContext, callback: SyncCallbackBlock? = nil) {
    self.context = context
    self.callback = callback
    super.init()
  }

  func sync(classes: [String]) {
    queue = classes.reverse()
    dequeue()
  }

  func dequeue() {
    if queue.count <= 0 { return }
    syncClass(queue.last!)
    queue.removeLast()
  }

  func syncClass(name: String) {
    if self.names[name] == nil { return }
    let objects = self.managedObjectsForClass(self.names[name]!, withSyncStatus: .Changed)
    let jsonObjects = objects.map{ $0.toJSON() }
    var params: JSONObject = [name: jsonObjects]
    params["api_key"] = kMyAPIKey
    let lastUpdate = self.mostRecentUpdatedAtDateForClass(self.names[name]!) ?? NSDate(timeIntervalSince1970: 0)
    params["updated_at"] = lastUpdate
    self.post(name, params: params)
  }

  private func post(name: String, params: JSONObject) {
    Alamofire.request(.POST, "\(kApiURL)/\(name)/sync", parameters: params)
      .responseJSON { (_, _, json, error) in
        if error == nil {
          let j = JSON(json!)
          self.handleResponse(j, name: name)
          self.dequeue()
        } else {
          println("sync error \(error)")
        }
      }
  }

  private func handleResponse(response: JSON, name: String) {
    if let objects = response.array {
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
        for json in objects {
          var object: NSManagedObject?
          object = self.findOrInitializeClass(self.names[name]!, guid: json["guid"].string!)
          if let object = object {
            if let jsonObject = json.object as? JSONObject {
              object.fromJSON(jsonObject,
                formatter: self.dateFormatter,
                context: self.context)
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
          println("success saving sync context")
        }
        dispatch_async(dispatch_get_main_queue()) {
          self.callback?()
        }
      }
    } else {
      println("json is not an array \(response)") // TODO: handle error
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

  func fromJSON(json: JSONObject,
    formatter: NSDateFormatter,
    context: NSManagedObjectContext) {
    fatalError("Method unimplemented")
  }

}

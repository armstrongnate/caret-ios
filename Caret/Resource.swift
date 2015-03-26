//
//  Resource.swift
//  Caret
//
//  Created by Nate Armstrong on 2/22/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import CoreData
import Alamofire

struct Resource<T where T: ResponseObjectSerializable, T: ResponseCollectionSerializable> {

  typealias CollectionResponse = (collection: [T]?) -> Void
  typealias ObjectResponse = (object: T?, error: NSError?) -> Void
  let name: String

  func all(parameters: [String:AnyObject]? = nil, completion: CollectionResponse? = nil) {
    var params = parameters ?? [:]
    params["api_key"] = kMyAPIKey
    Alamofire.request(.GET, "http://api.gocaret.com/\(name)", parameters: params)
      .responseCollection { (_, _, collection: [T]?, _) in
        println("get all \(self.name) (xcode bug)")
        completion?(collection: collection)
    }
  }

  func destroy(resourceID: NSNumber, parameters: [String:AnyObject]? = nil, completion: ObjectResponse? = nil) {
    var params = parameters ?? [:]
    params["api_key"] = kMyAPIKey
    Alamofire.request(.DELETE, "http://api.gocaret.com/\(name)/\(resourceID)", parameters: params)
      .responseObject { (_, _, object: T?, error) in
        if error != nil {
          println("error: \(error)")
        }
        completion?(object: object, error: error)
    }
  }

  func update(object: T, parameters: [String:AnyObject]? = nil, completion: ObjectResponse? = nil) {
    var params = parameters ?? [:]
    params["api_key"] = kMyAPIKey
    params += object.toJSON()
    Alamofire.request(.PATCH, "http://api.gocaret.com/\(name)/\(object.resourceID()!)", parameters: params)
      .responseObject { (_, _, object: T?, error) in
        if error != nil {
          println("error: \(error)")
        }
        completion?(object: object, error: error)
    }
  }

}

func +=<K, V> (inout left: [K : V], right: [K : V]) { for (k, v) in right { left[k] = v } }
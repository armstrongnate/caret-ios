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

let kMyAPIKey = "CLKcJvMU-faDZBBEgC_74Q"

struct Resource<T where T: ResponseObjectSerializable, T: ResponseCollectionSerializable> {

  typealias CollectionResponse = (collection: [T]?) -> Void
  let name: String

  func all(parameters: [String:AnyObject]? = nil, completion: CollectionResponse) {
    var params = parameters ?? [:]
    params["api_key"] = kMyAPIKey
    Alamofire.request(.GET, "http://api.gocaret.com/entries", parameters: params)
      .responseCollection { (_, _, collection: [T]?, _) in
        completion(collection: collection)
    }
  }

}

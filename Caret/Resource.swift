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
    Alamofire.request(.GET, "http://api.gocaret.com/entries", parameters: ["api_key": kMyAPIKey])
      .responseCollection { (_, _, collection: [T]?, _) in
        completion(collection: collection)
        println("collection.count = \(collection?.count)")
        println("collection = \(collection)")
    }
  }
}

class CaretAPI: NSObject {
  lazy var entries = Resource<Entry>(name: "entries")
}

class Caret {
  static var api: CaretAPI { return CaretAPI() }
}

final class Entry: NSObject {
  var notes: String = ""
}

extension Entry: ResponseObjectSerializable {
  convenience init?(response: NSHTTPURLResponse, representation: AnyObject) {
    self.init()
    self.notes = representation.valueForKeyPath("description") as! String
  }
}

extension Entry: ResponseCollectionSerializable {
  static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Entry] {
    var entries: [Entry] = []
    for dict in representation as! NSArray {
      if let entry = Entry(response: response, representation: dict as! NSObject) {
        entries.append(entry)
      }
    }
    return entries
  }
}

extension Entry: Printable {
  override var description: String {
    return self.notes ?? "no notes"
  }
}

extension Resource {
  func current<T: Entry>() {
    // TODO: this is an Entry specific method for retrieving current entry
  }
}

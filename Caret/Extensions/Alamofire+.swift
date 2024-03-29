//
//  Alamofire+.swift
//  Caret
//
//  Created by Nate Armstrong on 2/24/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation
import Alamofire

@objc public protocol ResponseObjectSerializable {
  init?(response: NSHTTPURLResponse, representation: AnyObject)
  func toJSON() -> [String: AnyObject]
  func resourceID() -> NSNumber?
}

extension Alamofire.Request {
  public func responseObject<T: ResponseObjectSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, T?, NSError?) -> Void) -> Self {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
      if response != nil && JSON != nil {
        return (T(response: response!, representation: JSON!), nil)
      } else {
        return (nil, serializationError)
      }
    }

    return response(serializer: serializer, completionHandler: { (request, response, object, error) in
      completionHandler(request, response, object as? T, error)
    })
  }
}

@objc public protocol ResponseCollectionSerializable {
  static func collection(#response: NSHTTPURLResponse, representation: AnyObject) -> [Self]
}

extension Alamofire.Request {
  public func responseCollection<T: ResponseCollectionSerializable>(completionHandler: (NSURLRequest, NSHTTPURLResponse?, [T]?, NSError?) -> Void) -> Self {
    let serializer: Serializer = { (request, response, data) in
      let JSONSerializer = Request.JSONResponseSerializer(options: .AllowFragments)
      let (JSON: AnyObject?, serializationError) = JSONSerializer(request, response, data)
      if response != nil && JSON != nil {
        return (T.collection(response: response!, representation: JSON!), nil)
      } else {
        return (nil, serializationError)
      }
    }

    return response(serializer: serializer, completionHandler: { (request, response, object, error) in
      completionHandler(request, response, object as? [T], error)
    })
  }
}

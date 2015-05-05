//
//  User.swift
//  Caret
//
//  Created by Nate Armstrong on 4/30/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import SwiftyJSON

class User: NSObject, NSCoding {

  let apiKeyKey = "apiKey"
  let firstNameKey = "firstName"
  let userIDKey = "userID"

  var apiKey: String
  var firstName: String
  var userID: Int

  static var current: User? {
    get {
      if let data = NSUserDefaults.standardUserDefaults().dataForKey("currentUser") {
        return NSKeyedUnarchiver.unarchiveObjectWithData(data) as? User
      }
      return nil
    }
    set {
      var archivedUser: NSData? = nil
      if let user = newValue {
        archivedUser = NSKeyedArchiver.archivedDataWithRootObject(user)
      }
      NSUserDefaults.standardUserDefaults().setObject(archivedUser, forKey: "currentUser")
    }
  }

  init(userID: Int, apiKey: String, firstName: String) {
    self.userID = userID
    self.apiKey = apiKey
    self.firstName = firstName
  }

  required init(coder decoder: NSCoder) {
    userID = Int(decoder.decodeIntForKey(userIDKey))
    apiKey = decoder.decodeObjectForKey(apiKeyKey) as! String
    firstName = decoder.decodeObjectForKey(firstNameKey) as! String
  }

  init(json: JSON) {
    userID = json["id"].numberValue.integerValue
    apiKey = json["api_key"].stringValue
    firstName = json["first_name"].stringValue
  }

  func encodeWithCoder(coder: NSCoder) {
    coder.encodeInt(Int32(userID), forKey: userIDKey)
    coder.encodeObject(apiKey, forKey: apiKeyKey)
    coder.encodeObject(firstName, forKey: firstNameKey)
  }

}

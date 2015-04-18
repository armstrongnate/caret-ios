//
//  Client.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import SwiftyJSON

extension Client {

  override func toJSON() -> JSONObject {
    return [
      "id": apiID ?? "",
      "name": name,
      "hourly_rate": hourly_rate,
      "guid": guid
    ]
  }

  func fromJSON(json: JSON, formatter: NSDateFormatter) {
    guid = json["guid"].string!
    apiID = json["id"].number
    name = json["name"].string!
    hourly_rate = json["hourly_rate"].numberValue
    archived = false // TODO: do something about archiving
    if let updated_at = json["updated_at"].string {
      self.updated_at = formatter.dateFromString(updated_at)
    }
  }

  override func fromJSON(json: JSONObject, formatter: NSDateFormatter) {
    fromJSON(JSON(json), formatter: formatter)
  }

}

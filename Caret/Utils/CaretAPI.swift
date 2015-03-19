//
//  CaretAPI.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

let kMyAPIKey = "CLKcJvMU-faDZBBEgC_74Q"

class CaretAPI: NSObject {

  struct Static {
    static var sharedInstance = CaretAPI()
  }

  class var sharedInstance: CaretAPI {
    get { return Static.sharedInstance }
    set { Static.sharedInstance = newValue }
  }

  lazy var entries = Resource<Entry>(name: "entries")


  // MARK: - Entries

  func getEntries(start: NSDate, to end: NSDate) {
    let format = "yyyy-MM-dd"
    let byRange = "\(start.stringWithFormat(format))," +
      "\(end.stringWithFormat(format))"

    entries.all(parameters: ["by_range": byRange]) { (entries) in
      Caret.stores.entries.create(entries ?? [])
    }
  }

  func getEntries(date: NSDate) {
    getEntries(date, to: date)
  }

}

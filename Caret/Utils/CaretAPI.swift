//
//  CaretAPI.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class CaretAPI: NSObject {

  struct Static {
    static var sharedInstance = CaretAPI()
  }

  class var sharedInstance: CaretAPI {
    get { return Static.sharedInstance }
    set { Static.sharedInstance = newValue }
  }

  lazy var entries = Resource<Entry>(name: "entries")
}

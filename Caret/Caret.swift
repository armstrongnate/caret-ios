//
//  Caret.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class Caret {

  class var api: CaretAPI { return CaretAPI.sharedInstance }
  class var stores: StoreManager { return StoreManager.defaultStoreManager }

}

class StoreManager: NSObject {

  struct Static {
    static var defaultStoreManager = StoreManager()
  }

  class var defaultStoreManager: StoreManager {
    get { return Static.defaultStoreManager }
    set { Static.defaultStoreManager = newValue }
  }

  lazy var entries: EntryStore = {
    return EntryStore()
  }()

}

//
//  Client.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

extension ClientEntity {

  enum SyncStatus: NSNumber {
    case NoChanges = 0
    case Changed = 1
    case Temporary = 2
  }

  var syncStatus: SyncStatus {
    get { return SyncStatus(rawValue: sync_status) ?? .Temporary }
    set { sync_status = newValue.rawValue }
  }

}

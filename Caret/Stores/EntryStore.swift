//
//  EntryStore.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntryStore: EventEmitter {

  var entries: [NSNumber: Entry] = [:]
  var entry: Entry?


  func emitChange() {
    emit(.Change)
  }

  func create(entries: [Entry]) {
    for entry in entries {
      if let id = entry.entryID {
        self.entries[id] = entry
      }
    }
    emitChange()
  }

  func getAllSorted() -> [Entry] {
    return sorted(entries.values) { $0.happenedOn.isEarlierThanDate($1.happenedOn) }
  }

  func clear() {
    entries = [:]
    emitChange()
  }

}

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
    dispatch_async(dispatch_get_main_queue()) {
      self.emit(.Change)
    }
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

  func update(entry: Entry) {
    if entries[entry.entryID!] != nil {
      entries[entry.entryID!] = entry
    }
    emitChange()
  }

  func remove(entry: Entry) {
    entries.removeValueForKey(entry.entryID!)
    emitChange()
  }

  func clear() {
    entries = [:]
    emitChange()
  }

}
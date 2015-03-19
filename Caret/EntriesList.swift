//
//  EntriesList.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntriesList: NSObject {

  var entries: [Entry] = []

  override init() {
    super.init()
    Caret.stores.entries.on(.Change, send: "onChange", to: self)
  }

  func onChange() {
    entries = Caret.stores.entries.getAllSorted()
  }
}

extension EntriesList: UITableViewDataSource {

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return entries.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath) as UITableViewCell
    let entry = entries[indexPath.row]
    cell.textLabel!.text = entry.notes
    cell.detailTextLabel!.text = entry.project?.name
    return cell
  }
}

//
//  EntriesList.swift
//  Caret
//
//  Created by Nate Armstrong on 3/18/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntriesList: NSObject {

  @IBOutlet weak var tableView: UITableView!

  var entries: [Entry] = []

  override init() {
    super.init()
    Caret.stores.entries.on(.Change, send: "onChange", to: self)
  }

  func onChange() {
    entries = Caret.stores.entries.getAllSorted()
    tableView.reloadData()
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
    var onceToken = dispatch_once_t()
    dispatch_once(&onceToken) {
      tableView.registerNib(UINib(nibName: "EntryTableViewCell",
        bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "entryCell")
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath) as EntryTableViewCell
    let entry = entries[indexPath.row]
    cell.projectLabel.text = entry.project?.name
    cell.entryDurationLabel.text = secondsToTime(entry.duration.integerValue)
    cell.entryNotesLabel.text = entry.notes
    return cell
  }

}

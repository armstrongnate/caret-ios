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

  var mergingCell: MergingCellImageView!
  var entries: [Entry] = []
  var editing: Bool
  var delegate: UITableViewDelegate?

  override init() {
    editing = false
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

    let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
    cell.addGestureRecognizer(longPress)
    return cell
  }

  func longPress(gesture: UILongPressGestureRecognizer) {
    let loc = gesture.locationInView(tableView.superview)
    let y = loc.y
    if gesture.state == .Began {
      let cell = gesture.view as EntryTableViewCell
      mergingCell = MergingCellImageView(image: imageWithView(cell))
      mergingCell.cell = cell
      mergingCell.alpha = 0.75
      mergingCell.center.y = y
      tableView.superview!.addSubview(mergingCell)
      cell.dragging = true
    }
    else if gesture.state == .Changed {
      pushScrollView(loc)
      checkMergeability(gesture.locationInView(tableView))
    }
    else if gesture.state == .Ended {
      mergingCell.removeFromSuperview()

      if let cellToKeep = cellAtPoint(gesture.locationInView(tableView)) {
        if let cellToMerge = mergingCell.cell {
          let entryToKeep = entries[tableView.indexPathForCell(cellToKeep)!.row]
          let entryToMerge = entries[tableView.indexPathForCell(cellToMerge)!.row]
          entryToKeep.duration = entryToKeep.duration.integerValue + entryToMerge.duration.integerValue
          Caret.api.updateEntry(entryToKeep)
          Caret.api.deleteEntry(entryToMerge)
        }
      }

      (mergingCell.cell as? EntryTableViewCell)?.dragging = false
      NSNotificationCenter.defaultCenter().postNotificationName(EntryBecameMergeableNotification, object: nil)
    }
  }

  func checkMergeability(point: CGPoint) {
    if let mergableCell = cellAtPoint(point) {
      if mergableCell != mergingCell.cell {
        mergableCell.mergeable = true
      }
    }
  }

  func cellAtPoint(point: CGPoint) -> EntryTableViewCell? {
    if let indexPath = tableView.indexPathForRowAtPoint(point) {
      return tableView.cellForRowAtIndexPath(indexPath) as? EntryTableViewCell
    }
    return nil
  }

  func pushScrollView(point: CGPoint) {
    mergingCell.center.y = point.y
    var offset: CGPoint?
    let offsetY = tableView.contentOffset.y
    let topY = CGRectGetMinY(mergingCell.frame)
    let bottomY = CGRectGetMaxY(mergingCell.frame)

    if topY <= tableView.frame.origin.y && offsetY > 0 {
      let dy = tableView.frame.origin.y - topY
      offset = CGPointMake(tableView.contentOffset.x, max(0, offsetY - dy))
    }
    if bottomY >= CGRectGetMaxY(tableView.frame) &&
      offsetY < tableView.contentSize.height - tableView.frame.size.height {
      let dy = bottomY - CGRectGetMaxY(tableView.frame)
      offset = CGPointMake(tableView.contentOffset.x, offsetY + dy)
    }
    if let offset = offset {
      tableView.setContentOffset(offset, animated: true)
    }
  }

}

extension EntriesList: UITableViewDelegate {

  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    if mergingCell.isDescendantOfView(tableView.superview!) {
      pushScrollView(mergingCell.center)
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    delegate?.tableView!(tableView, didSelectRowAtIndexPath: indexPath)
  }

}

class MergingCellImageView: UIImageView {

  var cell: UITableViewCell?

}

// Utils

func imageWithView(view: UIView) -> UIImage {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
  view.layer.renderInContext(UIGraphicsGetCurrentContext())
  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  return image
}

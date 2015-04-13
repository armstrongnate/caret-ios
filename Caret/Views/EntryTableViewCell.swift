//
//  EntryTableViewCell.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

let EntryBecameMergeableNotification = "EntryBecameMergeableNotification"

class EntryTableViewCell: UITableViewCell {

  @IBOutlet weak var projectLabel: UILabel!
  @IBOutlet weak var entryDurationLabel: UILabel!
  @IBOutlet weak var entryNotesLabel: UILabel!

  var mergeable: Bool = false {
    didSet {
      if mergeable {
        contentView.layer.borderColor = UIColor.secondaryColor().CGColor
        NSNotificationCenter.defaultCenter().postNotificationName(EntryBecameMergeableNotification, object: self)
      } else {
        contentView.layer.borderColor = UIColor.whiteColor().CGColor
      }
    }
  }

  var dragging: Bool = false {
    didSet {
      projectLabel.hidden = dragging
      entryDurationLabel.hidden = dragging
      entryNotesLabel.hidden = dragging
    }
  }

  override func awakeFromNib() {
    super.awakeFromNib()
    contentView.layer.borderWidth = 2.0
    contentView.layer.borderColor = UIColor.whiteColor().CGColor

    NSNotificationCenter.defaultCenter().addObserver(self,
      selector: "onMergeable:",
      name: EntryBecameMergeableNotification,
      object: nil)
  }

  func onMergeable(notification: NSNotification) {
    if (notification.object as? EntryTableViewCell) != self {
      mergeable = false
    }
  }

}

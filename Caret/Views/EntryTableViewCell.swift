//
//  EntryTableViewCell.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntryTableViewCell: UITableViewCell {

  @IBOutlet weak var projectLabel: UILabel!
  @IBOutlet weak var entryDurationLabel: UILabel!
  @IBOutlet weak var entryNotesLabel: UILabel!

  override func awakeFromNib() {
    super.awakeFromNib()
  }

}

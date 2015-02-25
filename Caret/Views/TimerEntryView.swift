//
//  TimerEntryView.swift
//  Caret
//
//  Created by Nate Armstrong on 2/25/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class TimerEntryView: UIView {

  @IBOutlet var view: UIView!

  required init(coder aCoder: NSCoder) {
    super.init(coder: aCoder)
    setup()
  }

  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setup()
  }

  private func setup() {
    NSBundle.mainBundle().loadNibNamed("TimerEntryView", owner: self, options: nil)
    addSubview(view)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    view.frame = bounds
  }

}

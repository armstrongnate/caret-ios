//
//  EntryAccessoryView.swift
//  Caret
//
//  Created by Nate Armstrong on 4/2/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

let descriptionFontSize: CGFloat = 17

class EntryAccessoryView: UIView {

  @IBOutlet weak var view: UIView!
  @IBOutlet weak var durationSlider: DurationSliderView!


  required init(coder aCoder: NSCoder) {
    super.init(coder: aCoder)
    setup()
  }

  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setup()
  }

  private func setup() {
    NSBundle.mainBundle().loadNibNamed("EntryAccessoryView", owner: self, options: nil)
    addSubview(view)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    view.frame = bounds
  }

}

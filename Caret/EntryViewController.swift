//
//  EntryViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntryViewController: UIViewController {

  let minAccessoryViewHeight: CGFloat = 52

  var entry: Entry!
  @IBOutlet weak var timerEntryView: TimerEntryView!
  lazy var entryAccessoryView: EntryAccessoryView = {
    let view = EntryAccessoryView(frame: CGRectMake(0, 0, 0, self.minAccessoryViewHeight))
    view.backgroundColor = UIColor.primaryColor()
    view.durationSlider.minimumValue = 0.0
    view.durationSlider.maximumValue = 12.0

    // TODO: this smells, use a protocol or something.
    view.durationSlider.addTarget(self.timerEntryView, action: "durationValueChanged:", forControlEvents: .ValueChanged)
    view.durationSlider.addTarget(self.timerEntryView, action: "zoomDurationSlider:", forControlEvents: .ApplicationReserved)
    view.durationSlider.addTarget(self.timerEntryView, action: "unzoomDurationSlider:", forControlEvents: .EditingDidEnd)
    return view
  }()

  override var inputAccessoryView: UIView? {
    return entryAccessoryView
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.
  }

  override func canBecomeFirstResponder() -> Bool {
    return true
  }

}

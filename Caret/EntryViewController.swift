//
//  EntryViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntryViewController: UITableViewController {

  var entry: Entry!
  lazy var durationSlider: DurationSliderView = {
    let slider = DurationSliderView()
    slider.addTarget(self, action: "durationValueChanged:", forControlEvents: .ValueChanged)
    return slider
  }()
  lazy var durationLabel: UILabel = {
    let label = UILabel(frame: CGRectZero)
    label.font = UIFont.systemFontOfSize(60)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    return label
  }()


  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Edit Entry"
    tableView.keyboardDismissMode = .Interactive
  }

  func durationValueChanged(durationSlider: DurationSliderView) {
    durationLabel.text = decimalMinutesToTime(durationSlider.value)
  }

}

// MARK: - Table view delegate

let durationHeaderHeight: CGFloat = 190
extension EntryViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
    if section == 0 {
      return durationHeaderHeight
    }
    return 35
  }

  override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
    if section == 0 {
      let view = UIView()
      view.backgroundColor = UIColor.primaryColor()
      let width = CGRectGetWidth(tableView.frame)
      let labelHeight = durationHeaderHeight - 44
      durationLabel.frame = CGRectMake(0, 0, width, labelHeight)
      durationLabel.text = "00:00"
      durationSlider.frame = CGRectMake(0, labelHeight, width, 44)
      durationSlider.minimumValue = 0
      durationSlider.maximumValue = 12
      view.addSubview(durationSlider)
      view.addSubview(durationLabel)
      return view
    }
    return nil
  }

}

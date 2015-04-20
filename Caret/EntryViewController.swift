//
//  EntryViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 3/19/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData

class EntryViewController: UITableViewController {

  @IBOutlet weak var projectLabel: UILabel!
  @IBOutlet weak var notesTextView: UITextView!
  @IBOutlet weak var happenedOnLabel: UILabel!

  var entry: Entry!
  var project: Project?
  var happenedOn: NSDate?
  var context: NSManagedObjectContext!
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
  lazy var dateFormatter: NSDateFormatter = {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "MM/dd/yyyy"
    return formatter
  }()


  override func viewDidLoad() {
    super.viewDidLoad()
    title = "Edit Entry"
    tableView.keyboardDismissMode = .Interactive
    projectLabel.text = project?.name ?? ""
    happenedOnLabel.text = ""
    if let happenedOn = happenedOn {
      happenedOnLabel.text = dateFormatter.stringFromDate(happenedOn)
    }
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    durationSlider.value = entry.duration.doubleValue / 60.0 / 60.0
  }

  @IBAction func save() {
    if let project = project, happenedOn = happenedOn {
      entry.duration = durationSlider.value * 60
      entry.notes = notesTextView.text
      entry.happened_on = NSDate() // TODO: use date from form
      entry.project = project
      var error: NSError?
      if context.save(&error) {
        performSegueWithIdentifier("unwindFromSaveEntry", sender: self)
//        syncController.sync(["entries"])
      }
    } else {
      // TODO: show that project is required
    }
  }

  func durationValueChanged(durationSlider: DurationSliderView) {
    durationLabel.text = decimalMinutesToTime(durationSlider.value)
  }

  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    tableView.reloadData()
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

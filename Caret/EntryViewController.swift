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
  var context: NSManagedObjectContext!
  var projectsContext: NSManagedObjectContext!
  var syncController: SyncController!
  var durationBackgroundView: UIView!
  lazy var durationSlider: DurationSliderView = {
    let slider = DurationSliderView()
    slider.delegate = self
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
    syncController = SyncController(context: context)
    durationSlider.value = entry.duration.doubleValue / 60.0 / 60.0
    notesTextView.text = entry.notes
    tableView.keyboardDismissMode = .Interactive
    projectLabel.text = project?.name ?? ""
    happenedOnLabel.text = dateFormatter.stringFromDate(entry.happened_on)
  }

  @IBAction func save() {
    if let project = project {
      entry.duration = durationSlider.value * 60 * 60
      entry.notes = notesTextView.text
      entry.happened_on = entry.happened_on
      entry.project = project
      entry.syncStatus = .Changed
      var error: NSError?
      if context.save(&error) {
        performSegueWithIdentifier("unwindFromSaveEntry", sender: self)
        syncController.sync(["entries"])
      } else {
        println("save entry context error \(error)")
      }
    } else {
      println("needs project and happened_on")
    }
  }

  func durationValueChanged(durationSlider: DurationSliderView) {
    durationLabel.text = decimalMinutesToTime(durationSlider.value)
  }

  override func viewWillTransitionToSize(size: CGSize, withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
    super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
    tableView.reloadData()
  }

  func pickProject() {
    let storyboard = UIStoryboard(name: "Project", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("projects") as! ProjectsViewController
    vc.context = projectsContext
    vc.delegate = self
    vc.navigationItem.rightBarButtonItem = nil
    navigationController!.pushViewController(vc, animated: true)
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
      durationBackgroundView = view
      return view
    }
    return nil
  }

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 0 && indexPath.row == 0 {
      pickProject()
    }
  }

}

// MARK: - Projects view controller delegate
extension EntryViewController: ProjectsViewControllerDelegate {

  func didSelectProject(project: Project) {
    self.project = project
    projectLabel.text = project.name
    tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0))!.setNeedsLayout()
    navigationController!.popViewControllerAnimated(true)
  }

}

// MARK: - Duration slider delegate
extension EntryViewController: DurationSliderViewDelegate {

  func durationSlider(durationSlider: DurationSliderView, zoomed: Bool) {
    let bgColor = zoomed ? UIColor(red: 66.0/255.0, green: 100.0/255.0, blue: 133.0/255.0, alpha: 1.0) : UIColor.primaryColor()
    let font = zoomed ? UIFont(name: "HelveticaNeue-Light", size: 60) : UIFont.systemFontOfSize(60)
    UIView.animateWithDuration(0.5) {
      self.durationLabel.font = font
      self.durationBackgroundView.backgroundColor = bgColor
    }
  }

}

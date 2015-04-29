//
//  AddGeoreminderViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/28/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import MapKit

protocol AddGeoreminderViewControllerDelegate {

  func addGeoreminderController(controller: AddGeoreminderViewController, didAddCoordinate coordinate: CLLocationCoordinate2D,
    radius: Double, identifier: String, onEntry: ClockEvent?, onExit: ClockEvent?)
}

class AddGeoreminderViewController: UITableViewController {

  @IBOutlet weak var mapView: MKMapView!

  @IBOutlet weak var entrySwitch: UISwitch!
  @IBOutlet weak var entrySegmentedControl: UISegmentedControl!

  @IBOutlet weak var exitSwitch: UISwitch!
  @IBOutlet weak var exitSegmentedControl: UISegmentedControl!

  var delegate: AddGeoreminderViewControllerDelegate?
  let radius: Double = 60
  var onEntry: ClockEvent? {
    return entrySwitch.on ? clockEventForSegmentedControl(entrySegmentedControl) : nil
  }
  var onExit: ClockEvent? {
    return exitSwitch.on ? clockEventForSegmentedControl(exitSegmentedControl) : nil
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.tableFooterView = UIView(frame: CGRectZero)
    entrySwitch.onTintColor = UIColor.secondaryColor()
    entrySwitch.tintColor = UIColor.secondaryColor()
    exitSwitch.onTintColor = UIColor.secondaryColor()
    exitSwitch.tintColor = UIColor.secondaryColor()

    entrySegmentedControl.tintColor = UIColor.primaryColor()
    exitSegmentedControl.tintColor = UIColor.primaryColor()

    entrySwitch.addTarget(self, action: "switchChanged:", forControlEvents: .ValueChanged)
    exitSwitch.addTarget(self, action: "switchChanged:", forControlEvents: .ValueChanged)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func onAdd(sender: UIBarButtonItem) {
    var coordinate = mapView.centerCoordinate
    var identifier = NSUUID().UUIDString
    delegate?.addGeoreminderController(self, didAddCoordinate: coordinate, radius: radius, identifier: identifier, onEntry: onEntry, onExit: onExit)
  }

  func switchChanged(control: UISwitch) {
    if !control.on {
      segmentedControlForSwitch(control).enabled = false
      otherSwitch(control).setOn(true, animated: true)
      segmentedControlForSwitch(otherSwitch(control)).enabled = true
    } else {
      segmentedControlForSwitch(control).enabled = true
    }
  }

  private func clockEventForSegmentedControl(control: UISegmentedControl) -> ClockEvent {
    return control.selectedSegmentIndex == 0 ? .In : .Out
  }

  private func segmentedControlForSwitch(control: UISwitch) -> UISegmentedControl {
    return control == entrySwitch ? entrySegmentedControl : exitSegmentedControl
  }

  private func otherSwitch(control: UISwitch) -> UISwitch {
    return control == entrySwitch ? exitSwitch : entrySwitch
  }

}

extension AddGeoreminderViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: false)
  }

}

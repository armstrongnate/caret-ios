//
//  FirstViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class EntriesViewController: UIViewController {

  @IBOutlet weak var weeklyCalendarView: CLWeeklyCalendarView!
  @IBOutlet weak var entriesData: EntriesList!

  var date = NSDate()

  override var editing: Bool {
    didSet {
      entriesData.editing = editing
    }
  }


  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupTabBarItem("entries")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // setup
    Caret.api.getProjects() { (projects) in
      Caret.api.getEntries(self.date)
    }
    weeklyCalendarView.delegate = self
    entriesData.delegate = self
    entriesData.tableView.estimatedRowHeight = 70.0
    entriesData.tableView.rowHeight = UITableViewAutomaticDimension
    entriesData.tableView.keyboardDismissMode = .Interactive
  }

  @IBAction func unwindFromEditEntry(segue: UIStoryboardSegue) {
    dismissViewControllerAnimated(true, completion: nil)
    Caret.api.getEntries(self.date)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "editEntry" {
      let indexPath = sender as! NSIndexPath
      let entry = Caret.stores.entries.getAllSorted()[indexPath.row]
      let entryForm = segue.destinationViewController.topViewController as! EntryViewController
      entryForm.entry = entry
    }
  }

}

// MARK: - Weekly calendar view delegate
extension EntriesViewController: CLWeeklyCalendarViewDelegate {

  func CLCalendarBehaviorAttributes() -> [NSObject : AnyObject]! {
    return [
      CLCalendarBackgroundImageColor : UIColor.primaryColor(),
      CLCalendarDayTitleTextColor : UIColor(white: 1.0, alpha: 0.6)
    ]
  }

  func dailyCalendarViewDidSelect(date: NSDate!) {
    self.date = date
    var strDate = date.stringWithFormat("d MMM yyy")
    if date.isToday() {
      strDate = "Today, \(strDate)"
    }
    navigationItem.title = strDate
    Caret.stores.entries.clear()
    Caret.api.getEntries(date)
  }

  func weeklyCalendarView(weeklyCalendarView: CLWeeklyCalendarView!, changedWeek date: NSDate!) {
    weeklyCalendarView.redrawToDate(date)
  }

}


// MARK: - Table view delegate
extension EntriesViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    performSegueWithIdentifier("editEntry", sender: indexPath)
  }
}

// MARK: - Text field delegate
extension EntriesViewController: UITextViewDelegate {

}

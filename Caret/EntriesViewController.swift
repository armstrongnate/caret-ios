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
  @IBOutlet weak var entriesTableView: UITableView!
  var data = EntriesList()

  var date = NSDate()


  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupTabBarItem("entries")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // setup
    Caret.stores.entries.on(.Change, send: "onChange", to: self)
    Caret.api.getProjects() { (projects) in
      Caret.api.getEntries(self.date)
    }
    weeklyCalendarView.delegate = self
    entriesTableView.dataSource = data
    entriesTableView.delegate = self

    // styles
    view.backgroundColor = UIColor.primaryColor()
    let navBar = navigationController!.navigationBar
    navBar.titleTextAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(14.0),
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
  }

  func onChange() {
    self.entriesTableView.reloadData()
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
    var strDate = date.stringWithFormat("EEE, d MMM yyy")
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
  // TODO
}

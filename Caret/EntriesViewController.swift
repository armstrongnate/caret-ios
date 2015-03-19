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
  @IBOutlet weak var swipeView: SwipeView!

  var date = NSDate()

  lazy var timerEntryView: UIView = {
    let timerView = TimerEntryView(frame: CGRectZero)
    return timerView
  }()

  lazy var entriesTableView: UIView = {
    return UITableView(frame: CGRectZero, style: .Plain)
  }()


  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    var selectedImage = UIImage(named: "tabbar-entries-selected")
    selectedImage = selectedImage?.imageWithRenderingMode(.AlwaysOriginal)
    var image = UIImage(named: "tabbar-entries")
    image = image?.imageWithRenderingMode(.AlwaysOriginal)
    tabBarItem = UITabBarItem(title: nil, image: nil, tag: 0)
    tabBarItem.image = image
    tabBarItem.selectedImage = selectedImage
    tabBarItem.imageInsets = UIEdgeInsets(top: 6, left: 0, bottom: -6, right: 0)

    tabBarController?.tabBar.tintColor = UIColor.grayColor()
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    Caret.api.entries.all(parameters: nil) { (collection: [Entry]?) in
    }
    view.backgroundColor = UIColor.primaryColor()
    weeklyCalendarView.delegate = self
    let navBar = navigationController!.navigationBar
    navBar.titleTextAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(14.0),
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
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
    swipeView.reloadData()
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEE, d MMM yyyy"
    var strDate = formatter.stringFromDate(date)
    if date.isDateToday() {
      strDate = "Today, \(strDate)"
    } else {
    }
    navigationItem.title = strDate
  }

  func weeklyCalendarViewChangedWeek(date: NSDate!) {
    weeklyCalendarView.redrawToDate(date)
  }

}

// MARK: - Swipe view data source
extension EntriesViewController: SwipeViewDataSource {

  func numberOfItemsInSwipeView(swipeView: SwipeView!) -> Int {
    return date.isDateToday() ? 1 : 1
  }

  func swipeView(swipeView: SwipeView!, viewForItemAtIndex index: Int, reusingView view: UIView!) -> UIView! {
    let frame = swipeView.frame
    if true || date.isDateToday() && index == 0 {
      timerEntryView.frame = swipeView.bounds
      return timerEntryView
    }
    entriesTableView.frame = swipeView.bounds
    return entriesTableView
  }

}

// MARK: - Swipe view delegate
//extension EntriesViewController: SwipeViewDelegate {
//  func swipeViewItemSize(swipeView: SwipeView!) -> CGSize {
//    var size = swipeView.frame.size
//    if date.isDateToday() && UIDevice.currentDevice().userInterfaceIdiom == .Pad { // TODO: work size classes?
//      size.width /= 2
//    }
//    return size
//  }
//}

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
    weeklyCalendarView.delegate = self
    let navBar = navigationController!.navigationBar
    navBar.titleTextAttributes = [
      NSFontAttributeName: UIFont.systemFontOfSize(14.0),
      NSForegroundColorAttributeName: UIColor.whiteColor()
    ]
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

extension EntriesViewController: CLWeeklyCalendarViewDelegate {
  func CLCalendarBehaviorAttributes() -> [NSObject : AnyObject]! {
    return [
      CLCalendarBackgroundImageColor : UIColor.primaryColor(),
      CLCalendarDayTitleTextColor : UIColor(white: 1.0, alpha: 0.6)
    ]
  }

  func dailyCalendarViewDidSelect(date: NSDate!) {
    let formatter = NSDateFormatter()
    formatter.dateFormat = "EEE, d MMM yyyy"
    var strDate = formatter.stringFromDate(date)
    if date.isDateToday() {
      strDate = "Today, \(strDate)"
    }
    navigationItem.title = strDate
  }

  func weeklyCalendarViewChangedWeek(date: NSDate!) {
    weeklyCalendarView.redrawToDate(date)
  }
}

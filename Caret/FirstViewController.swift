//
//  FirstViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class FirstViewController: UIViewController {

  @IBOutlet weak var weeklyCalendarView: CLWeeklyCalendarView!

  override func viewDidLoad() {
    super.viewDidLoad()
    weeklyCalendarView.delegate = self
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

}

extension FirstViewController: CLWeeklyCalendarViewDelegate {
  func CLCalendarBehaviorAttributes() -> [NSObject : AnyObject]! {
    return [
      CLCalendarBackgroundImageColor : UIColor.primaryColor(),
      CLCalendarDayTitleTextColor : UIColor(white: 1.0, alpha: 0.6)
    ]
  }

  func dailyCalendarViewDidSelect(date: NSDate!) {
    // noop
  }
}

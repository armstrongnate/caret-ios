//
//  CalendarViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/20/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import SwiftMoment

protocol CalendarViewControllerDelegate {
  func calendarView(calendarView: CalendarView, didSelectDate date: NSDate)
}

class CalendarViewController: UIViewController {

  @IBOutlet weak var calendar: CalendarView!

  var date: NSDate! {
    didSet {
      delegate?.calendarView(calendar, didSelectDate: date)
    }
  }
  var delegate: CalendarViewControllerDelegate?

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    automaticallyAdjustsScrollViewInsets = false
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    if date == nil {
      date = NSDate()
    } else {
      if !date.isToday() {
        calendar.selectDate(moment(date))
      }
    }
    title = date!.stringWithFormat("MMMM d, yyyy")

    calendar.delegate = self
    calendar.backgroundColor = UIColor.primaryColor()
    calendar.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-0-[calendar]",
      options: nil,
      metrics: nil,
      views: ["topGuide": topLayoutGuide, "calendar": calendar]))
  }

}

extension CalendarViewController: CalendarViewDelegate {

  func calendarDidSelectDate(date: Moment) {
    self.date = date.toNSDate()
    title = self.date!.stringWithFormat("MMMM d, yyyy")
  }

  func calendarDidPageToDate(date: Moment) {
    title = date.startOf(.Months).format(dateFormat: "MMMM d, yyyy")
  }
}

//
//  CalendarViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/20/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CalendarView
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
  var selectedDayOnPaged: Int? = 1
  var titleDateFormat = "MMMM d, yyyy"

  override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    automaticallyAdjustsScrollViewInsets = false
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    calendar.delegate = self
    calendar.backgroundColor = UIColor.primaryColor()
    calendar.selectedDayOnPaged = selectedDayOnPaged
    calendar.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-0-[calendar]",
      options: nil,
      metrics: nil,
      views: ["topGuide": topLayoutGuide, "calendar": calendar]))
  }

  override func viewWillAppear(animated: Bool) {
    super.viewWillAppear(animated)
    if date == nil {
      date = NSDate()
    } else {
      if !date.isToday() {
        calendar.selectDate(moment(date))
      }
    }
    title = date!.stringWithFormat(titleDateFormat)
  }

}

extension CalendarViewController: CalendarViewDelegate {

  func calendarDidSelectDate(date: Moment) {
    self.date = date.toNSDate()
    title = self.date!.stringWithFormat(titleDateFormat)
  }

  func calendarDidPageToDate(date: Moment) {
    title = date.startOf(.Months).format(dateFormat: titleDateFormat)
  }
}

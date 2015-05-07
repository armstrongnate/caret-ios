//
//  CalendarView.swift
//  Calendar
//
//  Created by Nate Armstrong on 3/27/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import SwiftMoment

protocol CalendarViewDelegate {
  func calendarDidSelectDate(date: Moment)
  func calendarDidPageToDate(date: Moment)
}

class CalendarView: UIView {

  private struct Appearance {
    static var dayBackgroundColor = UIColor.clearColor()
    static var daySelectedBackgroundColor = UIColor.orangeColor()
    static var todayBackgroundColor = UIColor.lightGrayColor()
    static var todayTextColor = UIColor.blackColor()
    static var dayTextColor = UIColor.blackColor()
    static var daySelectedTextColor = UIColor.whiteColor()
    static var otherMonthTextColor = UIColor.lightGrayColor()
    static var otherMonthBackgroundColor = UIColor.clearColor()
  }

  internal class var dayBackgroundColor: UIColor {
    get { return Appearance.dayBackgroundColor }
    set { Appearance.dayBackgroundColor = newValue }
  }
  internal class var daySelectedBackgroundColor: UIColor {
    get { return Appearance.daySelectedBackgroundColor }
    set { Appearance.daySelectedBackgroundColor = newValue }
  }
  internal class var todayBackgroundColor: UIColor {
    get { return Appearance.todayBackgroundColor }
    set { Appearance.todayBackgroundColor = newValue }
  }
  internal class var todayTextColor: UIColor {
    get { return Appearance.todayTextColor }
    set { Appearance.todayTextColor = newValue }
  }
  internal class var dayTextColor: UIColor {
    get { return Appearance.dayTextColor }
    set { Appearance.dayTextColor = newValue }
  }
  internal class var daySelectedTextColor: UIColor {
    get { return Appearance.daySelectedTextColor }
    set { Appearance.daySelectedTextColor = newValue }
  }
  internal class var otherMonthTextColor: UIColor {
    get { return Appearance.otherMonthTextColor }
    set { Appearance.otherMonthTextColor = newValue }
  }
  internal class var otherMonthBackgroundColor: UIColor {
    get { return Appearance.otherMonthBackgroundColor }
    set { Appearance.otherMonthBackgroundColor = newValue }
  }

  lazy var contentView: ContentView = {
    let cv = ContentView(frame: CGRectZero)
    cv.delegate = self
    self.addSubview(cv)
    return cv
  }()
  var delegate: CalendarViewDelegate? {
    didSet {
      delegate?.calendarDidPageToDate(contentView.currentMonth().date)
    }
  }
  var selectedDayOnPaged: Int? = 1

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  override func willMoveToWindow(newWindow: UIWindow?) {
    if newWindow == nil {
      NSNotificationCenter.defaultCenter().removeObserver(self)
      contentView.removeObservers()
    } else {
      NSNotificationCenter.defaultCenter().addObserver(self, selector: "dateSelected:", name: CalendarSelectedDayNotification, object: nil)
    }
  }

  func setup() {
    if let date = contentView.selectedDate {
      contentView.selectVisibleDate(date.day)
      delegate?.calendarDidSelectDate(moment(date))
      contentView.selectedDate = nil
    }
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    contentView.frame = bounds
    contentView.contentOffset.x = CGRectGetWidth(contentView.frame)
  }

  func dateSelected(notification: NSNotification) {
    if let date = notification.object as? NSDate {
      delegate?.calendarDidSelectDate(moment(date))
    }
  }

  func selectDate(date: Moment) {
    contentView.selectDate(date)
  }

}

extension CalendarView: UIScrollViewDelegate {

  func scrollViewDidScroll(scrollView: UIScrollView) {
    contentView.paged = false
    let ratio = contentView.contentOffset.x / CGRectGetWidth(contentView.frame)
    if ratio.isNaN { return }
    if ratio >= 2.0 || ratio <= 0.0 {
      contentView.selectPage(Int(ratio))
    }
  }

  func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
    contentView.setContentOffset(CGPointMake(CGRectGetWidth(contentView.frame), contentView.contentOffset.y), animated: true)
    delegate?.calendarDidPageToDate(contentView.currentMonth().date)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0)) {
      if let day = self.selectedDayOnPaged {
        let dayView = self.contentView.selectVisibleDate(day)
        dispatch_async(dispatch_get_main_queue()) {
          if let view = dayView {
            view.selected = true
          }
        }
      }
    }
  }

}

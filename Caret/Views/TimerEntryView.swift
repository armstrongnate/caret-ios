//
//  TimerEntryView.swift
//  Caret
//
//  Created by Nate Armstrong on 2/25/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class TimerEntryView: UIView {

  @IBOutlet weak var view: UIView!
  @IBOutlet weak var timerContainerView: UIView!
  @IBOutlet weak var durationSlider: DurationSliderView!
  @IBOutlet weak var durationLabel: UILabel!

  var zoomedLengthInMinutes: Double = 2

  required init(coder aCoder: NSCoder) {
    super.init(coder: aCoder)
    setup()
  }

  override init(frame aRect: CGRect) {
    super.init(frame: aRect)
    setup()
  }

  private func setup() {
    NSBundle.mainBundle().loadNibNamed("TimerEntryView", owner: self, options: nil)
    addSubview(view)

    timerContainerView.backgroundColor = UIColor.primaryColor()

    durationSlider.minimumValue = 0.0
    durationSlider.maximumValue = 12.0
    durationSlider.addTarget(self, action: "durationValueChanged:", forControlEvents: .ValueChanged)
    durationSlider.addTarget(self, action: "zoomDurationSlider:", forControlEvents: .ApplicationReserved)
    durationSlider.addTarget(self, action: "unzoomDurationSlider:", forControlEvents: .EditingDidEnd)
  }

  override func layoutSubviews() {
    super.layoutSubviews()
    view.frame = bounds
  }

  func durationValueChanged(sender: UIControl) {
    // TODO: update duration label
    durationLabel.text = decimalMinutesToTime(durationSlider.value)
    println("value changed!")
  }

  func zoomDurationSlider(sender: UIControl) {
    println("application reserved!")
    let locInView = whereIs(durationSlider.value, of: (0, 12), within: (Double(durationSlider.pixelMin), Double(durationSlider.pixelMax)))
    durationSlider.minimumValue = calcMin(from: durationSlider.value, at: locInView)
    durationSlider.maximumValue = calcMax(from: durationSlider.value, at: locInView)
  }

  func unzoomDurationSlider(sender: UIControl) {
    println("editing did end!")
    durationSlider.minimumValue = 0.0
    durationSlider.maximumValue = 12.0
  }

  func calcMin(#from: Double, at: Double) -> Double {
    let width = Double(durationSlider.pixelMax)
    return whereIs(Double(durationSlider.pixelMin), of: (at - width, at), within: (from-zoomedLengthInMinutes, from))
  }

  func calcMax(#from: Double, at: Double) -> Double {
    let width = Double(durationSlider.pixelMax)
    return whereIs(width, of: (at, width + at), within: (from, from+zoomedLengthInMinutes))
  }

}

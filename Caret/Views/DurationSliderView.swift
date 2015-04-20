//
//  DurationSliderView.swift
//  Caret
//
//  Created by Nate Armstrong on 2/25/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class DurationSliderView: UIControl {

  var phase = 0
  var numberOfPhases = 2
  var zoomedLengthInMinutes: Double = 2
  var value: Double = 0.0 {
    didSet {
      setNeedsLayout()
      sendActionsForControlEvents(.ValueChanged)
    }
  }
  var padding: CGFloat = 60
  let pinColor = UIColor.secondaryColor()
  let durationColor = UIColor.secondaryColor().colorWithAlphaComponent(0.80)
  let bgColor = UIColor.whiteColor()
  var minimumValue: Double = 0.0 {
    didSet {
      minLabel.text = decimalMinutesToTime(minimumValue)
      setNeedsLayout()
    }
  }
  var maximumValue: Double = 12.0 {
    didSet {
      maxLabel.text = decimalMinutesToTime(maximumValue)
      setNeedsLayout()
    }
  }
  var pixelMin: CGFloat {
    return 0 + padding - (CGRectGetWidth(pin.frame) / 2)
  }
  var pixelMax: CGFloat {
    return CGRectGetWidth(bounds) - padding
  }

  lazy var panGesture: PanPauseGestureRecognizer = {
    return PanPauseGestureRecognizer(target: self, action: "didPan:")
  }()

  lazy var pin: UIView = {
    let view = UIView(frame: CGRectMake(0, 0, 13.0, CGRectGetHeight(self.bounds)))
    view.backgroundColor = self.pinColor
    return view
  }()

  lazy var gestureView: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = UIColor(white: 0.0, alpha: 0.0)
    return view
  }()

  lazy var bottomBorder: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = UIColor.whiteColor()
    return view
  }()

  lazy var topBorder: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = UIColor.whiteColor()
    return view
  }()

  lazy var growView: UIView = {
    let view = UIView(frame: self.frame)
    view.backgroundColor = self.durationColor
    view.alpha = 0.4
    return view
  }()

  lazy var minLabel: UILabel = {
    let label = UILabel(frame: CGRectZero)
    label.font = UIFont.boldSystemFontOfSize(13)
    label.textColor = UIColor.whiteColor()
    label.textAlignment = .Center
    return label
  }()

  lazy var maxLabel: UILabel = {
    let label = UILabel(frame: CGRectZero)
    label.font = UIFont.boldSystemFontOfSize(13)
    label.textColor = UIColor.grayColor()
    label.textAlignment = .Center
    return label
  }()

  func setup() {
    backgroundColor = UIColor.whiteColor()
    addSubview(pin)
    addSubview(growView)
    gestureView.addGestureRecognizer(panGesture)
    addSubview(gestureView)
    addSubview(minLabel)
    addSubview(maxLabel)
  }

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setup()
  }

  override init(frame: CGRect) {
    super.init(frame: frame)
    setup()
  }

  override func layoutSubviews() {
    // pin
    pin.frame.origin.x = CGFloat(whereIs(value, of: (minimumValue, maximumValue), within: (Double(pixelMin), Double(pixelMax))))
    pin.frame.size.height = bounds.size.height
    var x: CGFloat = 3
    for i in 1...3 {
      var inner = UIView(frame: CGRectMake(x, 4, 1, bounds.size.height - 8))
      inner.backgroundColor = UIColor(red: 255.0/255.0, green: 186.0/255.0, blue: 143.0/255.0, alpha: 1.0)
      pin.addSubview(inner)
      x = CGRectGetMaxX(inner.frame) + 2
    }

    // growView
    growView.frame = bounds
    growView.frame.size.width = CGRectGetMinX(pin.frame)
    gestureView.frame = bounds

    // min/max labels
    let labelPad = CGRectGetWidth(pin.frame) / 2 + 5
    minLabel.frame = CGRectMake(0, 0, padding - labelPad, bounds.size.height)
    minLabel.adjustsFontSizeToFitWidth = true
    maxLabel.frame = CGRectMake(CGRectGetWidth(bounds) - padding + labelPad, 0, padding - labelPad, bounds.size.height)
    maxLabel.adjustsFontSizeToFitWidth = true

    // borders
    let borderHeight: CGFloat = 2
    bottomBorder.frame = CGRectMake(0, CGRectGetHeight(bounds) - borderHeight, CGRectGetWidth(bounds), borderHeight)
    topBorder.frame = CGRectMake(0, 0, CGRectGetWidth(bounds), borderHeight)
  }

  func drawLines() {
    for view in subviews {
      let v = view as! UIView
      if v != pin && v != gestureView && v != bottomBorder && v != topBorder {
        view.removeFromSuperview()
      }
    }
    var count: Double = 0
    while count <= maximumValue {
      let x = whereIs(count, of: (minimumValue, maximumValue), within: (Double(pixelMin), Double(pixelMax))) +
        Double(CGRectGetWidth(pin.frame) / 2)
      if count % 2 == 0 {
        let line = tallLineAt(CGFloat(x))
        insertSubview(line, atIndex: 0)
      } else {
        let line = smallLineAt(CGFloat(x))
        insertSubview(line, atIndex: 0)
      }
      count += 0.25
    }
  }

  func tallLineAt(x: CGFloat) -> UIView {
    let y = CGRectGetHeight(bounds) / 6
    let height = CGRectGetHeight(bounds) - y*2
    let width: CGFloat = 1.0
    let line = UIView(frame: CGRectMake(x, y, width, height))
    line.backgroundColor = UIColor.whiteColor()
    return line
  }

  func smallLineAt(x: CGFloat) -> UIView {
    let y = CGRectGetHeight(bounds) / 3
    let height = CGRectGetHeight(bounds) / 3
    let width: CGFloat = 0.5
    let line = UIView(frame: CGRectMake(x, y, width, height))
    line.backgroundColor = UIColor.whiteColor()
    line.alpha = 0.3
    return line
  }

  func didPan(gestureRecognizer: UIGestureRecognizer) {
    if gestureRecognizer.state == .Changed || gestureRecognizer.state == .Began {
      let panPauseGesture = gestureRecognizer as! PanPauseGestureRecognizer
      let x = gestureRecognizer.locationInView(self).x
      if panPauseGesture.paused {
        if phase++ < numberOfPhases - 1 {
          zoom(Double(x))
          panPauseGesture.paused = false
          panPauseGesture.startTimer()
        }
      }
      if x >= 0 && x <= CGRectGetWidth(bounds) {
        var loc = gestureRecognizer.locationInView(self).x
        if loc > pixelMax {
          loc = pixelMax
        } else if loc < pixelMin {
          loc = pixelMin
        }
        pin.frame.origin.x = loc - CGRectGetWidth(pin.frame) / 2
        growView.frame.size.width = CGRectGetMinX(pin.frame)
        setValueForLocation(loc)
        sendActionsForControlEvents(.ValueChanged)
      }
    } else if gestureRecognizer.state == .Ended || gestureRecognizer.state == .Cancelled {
      phase = 0
      unzoom()
    }
  }

  private func zoom(at: Double) {
    minimumValue = calcMin(from: value, at: at)
    maximumValue = calcMax(from: value, at: at)
  }

  private func unzoom() {
    minimumValue = 0.0
    maximumValue = 12.0
  }

  private func calcMin(#from: Double, at: Double) -> Double {
    let width = Double(pixelMax)
    return whereIs(Double(pixelMin), of: (at - width, at), within: (from-zoomedLengthInMinutes, from))
  }

  private func calcMax(#from: Double, at: Double) -> Double {
    let width = Double(pixelMax)
    return whereIs(width, of: (at, width + at), within: (from, from+zoomedLengthInMinutes))
  }

  private func setValueForLocation(loc: CGFloat) {
    value = whereIs(Double(loc), of: (Double(pixelMin), Double(pixelMax)), within: (minimumValue, maximumValue))
  }

}

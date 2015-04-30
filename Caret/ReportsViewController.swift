//
//  SecondViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import Charts
import CoreData

class ReportsViewController: UITableViewController {

  @IBOutlet weak var chartView: BarChartView!
  @IBOutlet weak var todayTotal: UILabel!
  @IBOutlet weak var weekTotal: UILabel!

  var context: NSManagedObjectContext!

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Reports"
    tableView.tableFooterView = UIView(frame: CGRectZero)

    chartView.drawGridBackgroundEnabled = false
    chartView.legend.enabled = false
    chartView.descriptionText = ""

    let xAxis = chartView.xAxis
    xAxis.labelPosition = .Bottom
    xAxis.drawGridLinesEnabled = false
    xAxis.labelFont = UIFont.systemFontOfSize(10)
    xAxis.spaceBetweenLabels = 0

    chartView.rightAxis.enabled = false

    let lAxis = chartView.leftAxis
    lAxis.gridColor = UIColor(white: 0.0, alpha: 0.1)

    setData()

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func setData() {
    let numbers = Numbers(context: context)
    var days = ["Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"]
    var weekTotal = 0.0
    var hours: [Float] = numbers.everyDayThisWeek().map { seconds in
      let hours = seconds / 3600.0
      weekTotal += hours
      return Float(hours)
    }

    self.weekTotal.text = String(format: "%.2f hrs", weekTotal)
    todayTotal.text = String(format: "%.2f hrs", numbers.today() / 3600.0)

    var yVals = [BarChartDataEntry]()

    for (index, h) in enumerate(hours) {
      yVals.append(BarChartDataEntry(value: h, xIndex: index))
    }

    let set = BarChartDataSet(yVals: yVals, label: "")
    set.barSpace = 0.35
    set.setColor(UIColor.secondaryColor())

    let data = BarChartData(xVals: days, dataSet: set)
    chartView.data = data

    if chartView.leftAxis.axisMaximum < 8.0 {
      chartView.leftAxis.customAxisMax = 8
      chartView.rightAxis.customAxisMax = 8
    }
  }

}

extension ReportsViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }
}


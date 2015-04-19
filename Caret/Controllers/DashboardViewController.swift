//
//  DashboardViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/12/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import Charts

protocol PersistenceViewController {

  var persistenceController: PersistenceController { get set }

}

class DashboardViewController: UIViewController {

  struct ListItem {
    let title: String
    let subtitle: String
    let storyboard: String
    let identifier: String
  }

  var persistenceController: PersistenceController!

  @IBOutlet weak var chartView: BarChartView!
  @IBOutlet weak var tableView: UITableView!

  var items: [ListItem] = [
    ListItem(title: "Time Clock", subtitle: "Your current running timer.", storyboard: "Main", identifier: "entries"),
    ListItem(title: "Reports", subtitle: "Description of what's behind this curtain.", storyboard: "", identifier: ""),
    ListItem(title: "Clients", subtitle: "Description of what's behind this curtain.", storyboard: "Client", identifier: "clients"),
    ListItem(title: "Projects", subtitle: "Description of what's behind this curtain.", storyboard: "Project", identifier: "projects"),
    ListItem(title: "Users", subtitle: "Description of what's behind this curtain.", storyboard: "", identifier: ""),
    ListItem(title: "Invoices", subtitle: "Description of what's behind this curtain.", storyboard: "", identifier: ""),
  ]


  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.dataSource = self
    tableView.delegate = self

    chartView.setTranslatesAutoresizingMaskIntoConstraints(false)
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[topGuide]-20-[chartView]",
      options: nil,
      metrics: nil,
      views: ["topGuide": topLayoutGuide, "chartView": chartView]))
    view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[tableView]-0-[bottomGuide]",
      options: nil,
      metrics: nil,
      views: ["bottomGuide": bottomLayoutGuide, "tableView": tableView]))

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

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    title = "Dashboard"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func setData() {
    var days = ["Sun", "Mon", "Tue", "Wed", "Thur", "Fri", "Sat"]
    var hours: [Float] = [0.0, 6.18, 0.0, 0.0, 0.0, 0.0, 0.0]
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

// MARK: - Table view data source
extension DashboardViewController: UITableViewDataSource {

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return 1
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return items.count
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let item = items[indexPath.row]

    var cell = tableView.dequeueReusableCellWithIdentifier("Cell") as? UITableViewCell
    if cell == nil {
      cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "Cell")
    }

    cell!.textLabel!.text = item.title
    cell!.detailTextLabel!.text = item.subtitle

    return cell!
  }

}

// MARK: - Table view delegate
extension DashboardViewController: UITableViewDelegate {

  func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
    return 70
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    let item = items[indexPath.row]
    let identifier = item.identifier
    let storyboard = UIStoryboard(name: item.storyboard, bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier(item.identifier) as! UIViewController
    if identifier == "clients" {
      (vc as! ClientsViewController).context = persistenceController.managedObjectContext
    }
    else if identifier == "projects" {
      (vc as! ProjectsViewController).context = persistenceController.managedObjectContext
    }
    navigationController!.pushViewController(vc, animated: true)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}

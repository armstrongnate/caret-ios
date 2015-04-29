//
//  SettingsViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/27/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData

class SettingsViewController: UITableViewController {

  var context: NSManagedObjectContext!
  typealias tableRowAction = () -> Void
  lazy var tableActions: [[tableRowAction]] = {
    return [
      [self.reports, self.notifications],
      [self.clients, self.projects],
      [self.logOut]
    ]
  }()

  override func viewDidLoad() {
    super.viewDidLoad()

    title = "Settings"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func reports() {
  }

  func notifications() {
    performSegueWithIdentifier("notifications", sender: self)
  }

  func clients() {
    let storyboard = UIStoryboard(name: "Client", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("clients") as! ClientsViewController
    vc.context = context
    navigationController!.pushViewController(vc, animated: true)
  }

  func projects() {
    let storyboard = UIStoryboard(name: "Project", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("projects") as! ProjectsViewController
    vc.context = context
    navigationController!.pushViewController(vc, animated: true)
  }

  func logOut() {
  }

}

extension SettingsViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    tableActions[indexPath.section][indexPath.row]()
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}

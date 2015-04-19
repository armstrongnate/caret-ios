//
//  ProjectViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData

class ProjectViewController: UITableViewController {

  var project: Project!
  var client: Client? {
    didSet {
      clientLabel?.text = client?.name ?? "Select Client"
    }
  }
  var context: NSManagedObjectContext! // set by source
  var syncController: SyncController!

  @IBOutlet weak var nameTextField: UITextField!
  @IBOutlet weak var hourlyRateTextField: UITextField!
  @IBOutlet weak var clientLabel: UILabel!

  override func viewDidLoad() {
    super.viewDidLoad()
    syncController = SyncController(context: context)
    nameTextField.text = project.name
    hourlyRateTextField.text = project.hourly_rate.description
    clientLabel.text = client?.name ?? "Select Client"
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func save(sender: AnyObject) {
    if let client = client {
      project.name = nameTextField.text
      project.hourly_rate = NSNumber(double: (hourlyRateTextField.text as NSString).doubleValue)
      project.syncStatus = .Changed
      project.archived = false
      project.client = client
      var error: NSError?
      if context.save(&error) {
        performSegueWithIdentifier("unwindFromSaveProject", sender: self)
        syncController.sync(["projects"])
      }
    } else {
      // TODO: show that client is required
    }
  }

  func pickClient() {
    let storyboard = UIStoryboard(name: "Client", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("clients") as! ClientsViewController
    vc.context = context.parentContext
    vc.delegate = self
    navigationController!.pushViewController(vc, animated: true)
  }
  
}

// MARK: - Table view delegate
extension ProjectViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if indexPath.section == 1 && indexPath.row == 0 {
      pickClient()
    }
  }
}

// MARK: - Clients view controller delegate
extension ProjectViewController: ClientsViewControllerDelegate {

  func didSelectClient(client: Client) {
    self.client = client
    navigationController!.popViewControllerAnimated(true)
  }

}

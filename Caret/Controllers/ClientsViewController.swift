//
//  ClientsViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData
import SwiftMoment

protocol ClientsViewControllerDelegate {

  func didSelectClient(client: Client)

}

class ClientsViewController: UITableViewController {

  var context: NSManagedObjectContext!
  var syncController: SyncController!
  var delegate: ClientsViewControllerDelegate?
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: self.context)
    fetchRequest.entity = entity
    let sort = NSSortDescriptor(key: "name", ascending: true)
    fetchRequest.sortDescriptors = [sort]
    let controller = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.context,
      sectionNameKeyPath: nil,
      cacheName: "Root"
    )
    controller.delegate = self
    return controller
  }()

  override func viewDidLoad() {
    super.viewDidLoad()
    var error: NSError? = nil
    if !fetchedResultsController.performFetch(&error) {
      println("fetch error \(error)")
    }

    let syncContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    syncContext.parentContext = context
    syncController = SyncController(context: syncContext) {
      self.refreshControl?.endRefreshing()
    }

    refreshControl = UIRefreshControl()
    refreshControl!.backgroundColor = UIColor.primaryColor()
    refreshControl!.tintColor = UIColor.whiteColor()
    refreshControl!.addTarget(self, action: "sync", forControlEvents: .ValueChanged)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func unwindFromCancelClient(segue: UIStoryboardSegue) {
    // noop
  }

  @IBAction func unwindFromSaveClient(segue: UIStoryboardSegue) {
    // noop
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let client = fetchedResultsController.objectAtIndexPath(indexPath) as! Client
    cell.textLabel!.text = client.name
    cell.detailTextLabel!.text = "$\(client.hourly_rate.description)/hr"
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "newClient" || segue.identifier == "editClient" {
      let controller = segue.destinationViewController.topViewController as! ClientViewController
      let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      childContext.parentContext = context

      let client: Client
      if segue.identifier == "newClient" {
        controller.title = "New Client"
        client = NSEntityDescription.insertNewObjectForEntityForName("Client",
          inManagedObjectContext: childContext) as! Client
        client.apiID = nil
        client.guid = NSUUID().UUIDString
        client.name = ""
        client.hourly_rate = 100 // TODO: use settings hourly rate
      } else {
        controller.title = "Edit Client"
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        client = fetchedResultsController.objectAtIndexPath(indexPath) as! Client
      }

      controller.client = client
      controller.context = childContext
    }
  }

  func sync() {
    syncController.sync(["clients"])
  }

}

// MARK: - Table view data source
extension ClientsViewController: UITableViewDataSource {

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sectionInfo: AnyObject = fetchedResultsController.sections?[section] {
      return sectionInfo.numberOfObjects
    }
    return 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ClientCell", forIndexPath: indexPath) as! UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

}

// MARK: - Table view delegate
extension ClientsViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let delegate = delegate {
      delegate.didSelectClient(fetchedResultsController.objectAtIndexPath(indexPath) as! Client)
    } else {
      performSegueWithIdentifier("editClient", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}

// MARK: - Fetched results controller delegate
extension ClientsViewController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
    refreshControl?.endRefreshing()
  }

  func controller(controller: NSFetchedResultsController,
    didChangeObject anObject: AnyObject,
    atIndexPath indexPath: NSIndexPath?,
    forChangeType type: NSFetchedResultsChangeType,
    newIndexPath: NSIndexPath?) {
    switch type {
      case .Insert:
        tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
      case .Delete:
        tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
      case .Update:
        self.configureCell(tableView.cellForRowAtIndexPath(indexPath!)!, atIndexPath: indexPath!)
      default:
        return
    }
  }

  func controller(controller: NSFetchedResultsController,
    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
    atIndex sectionIndex: Int,
    forChangeType type: NSFetchedResultsChangeType) {
    switch type {
      case .Insert:
        self.tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      case .Delete:
        self.tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
      default:
        return
    }
  }

}

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

class ClientsViewController: UITableViewController {

  var persistenceController: PersistenceController!
  var syncController: SyncController!
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Client", inManagedObjectContext: self.persistenceController.managedObjectContext)
    fetchRequest.entity = entity
    let sort = NSSortDescriptor(key: "updated_at", ascending: false)
    fetchRequest.sortDescriptors = [sort]
    let controller = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.persistenceController.managedObjectContext,
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
    syncContext.parentContext = persistenceController.managedObjectContext
    syncController = SyncController(context: syncContext)
    syncController.delegate = self
    NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextDidSaveNotification,
      object: nil, queue: nil) { (notif) -> Void in
      if let savedContext = notif.object as? NSManagedObjectContext {
        if savedContext == syncContext {
          self.persistenceController.managedObjectContext?.mergeChangesFromContextDidSaveNotification(notif)
        }
      }
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
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func unwindFromSaveClient(segue: UIStoryboardSegue) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let client = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Client
    cell.textLabel!.text = client.name
    cell.detailTextLabel!.text = client.updated_at?.description ?? "Not synced"
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "newClient" {
      let controller = segue.destinationViewController.topViewController as! ClientViewController
      let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      childContext.parentContext = persistenceController.managedObjectContext
      let newClient = NSEntityDescription.insertNewObjectForEntityForName("Client",
        inManagedObjectContext: childContext) as! Client
      newClient.guid = NSUUID().UUIDString
      controller.title = "New Client"
      controller.client = newClient
      controller.context = childContext
      controller.syncController = syncController
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

// MARK: - Sync controller delegate
extension ClientsViewController: SyncControllerDelegate {

  func syncFinished() {
    refreshControl?.endRefreshing()
  }
}

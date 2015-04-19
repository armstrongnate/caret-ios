//
//  ProjectsViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData
import SwiftMoment

protocol ProjectsViewControllerDelegate {

  func didSelectProject(project: Project)

}

class ProjectsViewController: UITableViewController {

  var context: NSManagedObjectContext!
  var syncController: SyncController!
  var delegate: ProjectsViewControllerDelegate?
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Project", inManagedObjectContext: self.context)
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

  @IBAction func unwindFromCancelProject(segue: UIStoryboardSegue) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  @IBAction func unwindFromSaveProject(segue: UIStoryboardSegue) {
    dismissViewControllerAnimated(true, completion: nil)
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let project = fetchedResultsController.objectAtIndexPath(indexPath) as! Project
    cell.textLabel!.text = project.name
    cell.detailTextLabel!.text = "$\(project.hourly_rate.description)/hr"
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "newProject" || segue.identifier == "editProject" {
      let controller = segue.destinationViewController.topViewController as! ProjectViewController
      let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      childContext.parentContext = context

      let project: Project
      if segue.identifier == "newProject" {
        controller.title = "New Project"
        project = NSEntityDescription.insertNewObjectForEntityForName("Project",
          inManagedObjectContext: childContext) as! Project
        project.guid = NSUUID().UUIDString
        project.name = ""
        project.hourly_rate = 100 // TODO: use settings hourly rate
      } else {
        controller.title = "Edit Project"
        let cell = sender as! UITableViewCell
        let indexPath = tableView.indexPathForCell(cell)!
        project = fetchedResultsController.objectAtIndexPath(indexPath) as! Project
        controller.client = project.client
      }

      controller.project = project
      controller.context = childContext
    }
  }

  func sync() {
    syncController.sync(["projects"])
  }

}

// MARK: - Table view data source
extension ProjectsViewController: UITableViewDataSource {

  override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sectionInfo: AnyObject = fetchedResultsController.sections?[section] {
      return sectionInfo.numberOfObjects
    }
    return 0
  }

  override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCellWithIdentifier("ProjectCell", forIndexPath: indexPath) as! UITableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

}

// MARK: - Table view delegate
extension ProjectsViewController: UITableViewDelegate {

  override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if let delegate = delegate {
      delegate.didSelectProject(fetchedResultsController.objectAtIndexPath(indexPath) as! Project)
    } else {
      performSegueWithIdentifier("editProject", sender: tableView.cellForRowAtIndexPath(indexPath))
    }
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}

// MARK: - Fetched results controller delegate
extension ProjectsViewController: NSFetchedResultsControllerDelegate {

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

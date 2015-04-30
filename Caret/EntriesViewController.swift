//
//  FirstViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData
import SwiftMoment

class EntriesViewController: UIViewController {

  @IBOutlet weak var weeklyCalendarView: CLWeeklyCalendarView!
  @IBOutlet weak var tableView: UITableView!

  // title bar
  @IBOutlet weak var titleView: UIView!
  @IBOutlet weak var editButton: UIBarButtonItem!
  @IBOutlet weak var addButton: UIBarButtonItem!
  @IBOutlet weak var doneButton: UIBarButtonItem!
  @IBOutlet weak var mergeButton: UIBarButtonItem!
  @IBOutlet weak var deleteButton: UIBarButtonItem!
  @IBOutlet weak var calendarButton: UIBarButtonItem!
  @IBOutlet weak var settingsButton: UIBarButtonItem!
  @IBOutlet weak var dayLabel: UILabel!
  @IBOutlet weak var dayTotal: UILabel!

  // toolbar
  @IBOutlet weak var clockInOutButton: UIBarButtonItem!
  @IBOutlet weak var durationButton: DurationBarButtonItem!

  var context: NSManagedObjectContext!
  var timerController: TimerController!
  lazy var syncController: SyncController = {
    let syncContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    syncContext.parentContext = self.context
    let syncController = SyncController(context: syncContext) {
      self.refreshControl.endRefreshing()
    }
    return syncController
  }()
  var date: NSDate! {
    didSet {
      var strDate = date.stringWithFormat("MM/dd/yyyy")
      if date.isToday() {
        strDate = "Today"
      }
      dayLabel.text = strDate
      performFetch()
      setDayTotal()
    }
  }
  var mergingCell: MergingCellImageView!
  lazy var refreshControl: UIRefreshControl = {
    let refreshControl = UIRefreshControl()
    refreshControl.backgroundColor = UIColor.primaryColor()
    refreshControl.tintColor = UIColor.whiteColor()
    return refreshControl
  }()
  lazy var fetchedResultsController: NSFetchedResultsController = {
    let fetchRequest = NSFetchRequest()
    let entity = NSEntityDescription.entityForName("Entry", inManagedObjectContext: self.context)
    fetchRequest.entity = entity
    let sort = NSSortDescriptor(key: "project.name", ascending: true)
    fetchRequest.sortDescriptors = [sort]
    let controller = NSFetchedResultsController(
      fetchRequest: fetchRequest,
      managedObjectContext: self.context,
      sectionNameKeyPath: nil,
      cacheName: nil
    )
    controller.delegate = self
    return controller
  }()


  override func viewDidLoad() {
    super.viewDidLoad()

    // refresh control
    let refreshControlTableViewController = UITableViewController(style: tableView.style)
    refreshControlTableViewController.tableView = tableView
    refreshControlTableViewController.refreshControl = refreshControl
    refreshControl.addTarget(self, action: "sync", forControlEvents: .ValueChanged)

    sync()

    // setup
    durationButton.timerController = timerController
    durationButton.delegate = self
    timerController.delegate = self
    lastEntryEndedAtDidUpdate(nil)
    weeklyCalendarView.delegate = self
    tableView.estimatedRowHeight = 70.0
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.allowsMultipleSelectionDuringEditing = true
    date = NSDate()
    performFetch()

    // bar button items
    navigationItem.rightBarButtonItems = [editButton, addButton]
    navigationItem.leftBarButtonItems = [calendarButton, settingsButton]
    titleView.autoresizingMask = UIViewAutoresizing.FlexibleWidth | UIViewAutoresizing.FlexibleLeftMargin | UIViewAutoresizing.FlexibleRightMargin
    titleView.autoresizesSubviews = true
    navigationItem.titleView = titleView
    navigationController!.toolbarHidden = false
  }

  override func viewDidAppear(animated: Bool) {
    super.viewDidAppear(animated)
    timerController.update()
  }

  @IBAction func unwindFromEditEntry(segue: UIStoryboardSegue) {
    // noop
  }

  @IBAction func unwindFromSettings(segue: UIStoryboardSegue) {
    // noop
  }

  @IBAction func unwindFromSaveEntry(segue: UIStoryboardSegue) {
    performFetch()
  }

  @IBAction func editButtonPressed(sender: UIBarButtonItem) {
    tableView.editing = true
    navigationItem.rightBarButtonItems = [doneButton, mergeButton, deleteButton]
  }

  @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
    tableView.editing = false
    navigationItem.rightBarButtonItems = [editButton, addButton]
  }

  @IBAction func mergeButtonPressed(sender: UIBarButtonItem) {
    var firstEntry: Entry!
    if let selectedRows = tableView.indexPathsForSelectedRows() {
      if selectedRows.count <= 1 { return }
      for (index, indexPath) in enumerate(selectedRows) {
        let indexPath = indexPath as! NSIndexPath
        if index == 0 {
          firstEntry = fetchedResultsController.objectAtIndexPath(indexPath) as! Entry
        } else {
          let entry = fetchedResultsController.objectAtIndexPath(indexPath) as! Entry
          firstEntry.duration = firstEntry.duration.integerValue + entry.duration.integerValue
          firstEntry.syncStatus = .Changed
          entry.archived = true
          entry.syncStatus = .Changed
        }
      }
      sync()
    }
  }

  @IBAction func deleteButtonPressed(sender: UIBarButtonItem) {
    if let selectedRows = tableView.indexPathsForSelectedRows() {
      for indexPath in selectedRows {
        let indexPath = indexPath as! NSIndexPath
        let entry = fetchedResultsController.objectAtIndexPath(indexPath) as! Entry
        entry.archived = true
        entry.syncStatus = .Changed
      }
      sync()
    }
  }

  @IBAction func calendarButtonPressed(sender: UIBarButtonItem) {
    let calendar = CalendarViewController(nibName: "CalendarViewController", bundle: nil)
    calendar.date = date
    calendar.delegate = self
    calendar.selectedDayOnPaged = nil
    calendar.titleDateFormat = "MMMM yyyy"
    let nav = UINavigationController(rootViewController: calendar)
    presentViewController(nav, animated: true, completion: nil)
  }

  @IBAction func settingsButtonPressed(sender: UIBarButtonItem) {
    let storyboard = UIStoryboard(name: "Settings", bundle: nil)
    let nav = storyboard.instantiateViewControllerWithIdentifier("settingsNavigationController") as! UINavigationController
    (nav.topViewController as! SettingsViewController).context = context
    presentViewController(nav, animated: true, completion: nil)
  }

  @IBAction func clockInOutButtonPressed(sender: UIBarButtonItem) {
    timerController.clockedIn ? timerController.clockOut() : timerController.clockIn()
    clockInOutButton.title = timerController.clockedIn ? "Clock out" : "Clock in"
  }

  @IBAction func durationButtonPressed(sender: UIBarButtonItem) {
    performSegueWithIdentifier("newEntry", sender: sender)
  }

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "newEntry" || segue.identifier == "editEntry" {
      let entryForm = segue.destinationViewController.topViewController as! EntryViewController
      let childContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
      childContext.parentContext = context

      let entry: Entry
      if segue.identifier == "newEntry" {
        entry = NSEntityDescription.insertNewObjectForEntityForName("Entry", inManagedObjectContext: childContext) as! Entry
        entry.apiID = nil
        entry.guid = ""
        entry.notes = ""
        entry.happened_on = date
        entry.archived = false
        if let durationButton = sender as? DurationBarButtonItem {
          entry.duration = timerController.interval
        } else {
          entry.duration = 0
        }
        entryForm.projectsContext = childContext
      } else {
        let indexPath = sender as! NSIndexPath
        entry = fetchedResultsController.objectAtIndexPath(indexPath) as! Entry
        entryForm.project = entry.project
        entryForm.projectsContext = context
      }

      entryForm.entry = entry
      entryForm.context = childContext
    }
  }

  func configureCell(cell: UITableViewCell, atIndexPath indexPath: NSIndexPath) {
    let cell = cell as! EntryTableViewCell
    let entry = fetchedResultsController.objectAtIndexPath(indexPath) as! Entry
    cell.entryDurationLabel.text = secondsToTime(entry.duration.integerValue)
    cell.entryNotesLabel.text = entry.notes
    cell.projectLabel.text = entry.project.name
    cell.tintColor = UIColor.secondaryColor()

    let longPress = UILongPressGestureRecognizer(target: self, action: "longPress:")
    cell.addGestureRecognizer(longPress)
  }

  func performFetch() {
    let dayStart = moment(self.date).startOf(.Days).toNSDate()!
    let dayEnd = moment(self.date).endOf("d").toNSDate()!
    let predicate = NSPredicate(format: "(archived == 0) AND (happened_on >= %@) AND (happened_on <= %@)", dayStart, dayEnd)
    self.fetchedResultsController.fetchRequest.predicate = predicate
    var error: NSError?
    if self.fetchedResultsController.performFetch(&error) {
      tableView.reloadData()
    } else {
      println("entries fetch error \(error)")
    }
  }

  func sync() {
    let syncContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    syncContext.parentContext = context
    syncController.context = syncContext
    syncController.sync(["entries"])
    timerController.update()
  }

  func setDayTotal() {
    if let entries = fetchedResultsController.fetchedObjects as? [Entry] {
      var totalSeconds = entries.reduce(0) { $0 + $1.duration.integerValue }
      totalSeconds += Int(timerController.interval)
      dayTotal.text = "\(secondsToTime(totalSeconds)) total"
    }
  }

}

// MARK: - Weekly calendar view delegate
extension EntriesViewController: CLWeeklyCalendarViewDelegate {

  func CLCalendarBehaviorAttributes() -> [NSObject : AnyObject]! {
    return [
      CLCalendarBackgroundImageColor : UIColor.primaryColor(),
      CLCalendarDayTitleTextColor : UIColor(white: 1.0, alpha: 0.6)
    ]
  }

  func dailyCalendarViewDidSelect(date: NSDate!) {
    self.date = date
  }

  func weeklyCalendarView(weeklyCalendarView: CLWeeklyCalendarView!, changedWeek date: NSDate!) {
    weeklyCalendarView.redrawToDate(date)
  }

}

// MARK: - Calendar view controller delegate
extension EntriesViewController: CalendarViewControllerDelegate {

  func calendarView(calendarView: CalendarView, didSelectDate date: NSDate) {
    self.date = date
    weeklyCalendarView.redrawToDate(date)
    dismissViewControllerAnimated(true) { completed in
      self.weeklyCalendarView.redrawToDate(date)
    }
  }

}

// MARK: - Table view delegate
extension EntriesViewController: UITableViewDelegate {

  func scrollViewDidEndScrollingAnimation(scrollView: UIScrollView) {
    if mergingCell == nil { return }
    if let superview = tableView.superview {
      if mergingCell.isDescendantOfView(superview) {
        pushScrollView(mergingCell.center)
      }
    }
  }

  func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
    if tableView.editing {
      return
    }
    performSegueWithIdentifier("editEntry", sender: indexPath)
    tableView.deselectRowAtIndexPath(indexPath, animated: true)
  }

}

// MARK: - Table view data source
extension EntriesViewController: UITableViewDataSource {

  func numberOfSectionsInTableView(tableView: UITableView) -> Int {
    return fetchedResultsController.sections?.count ?? 0
  }

  func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    if let sectionInfo: AnyObject = fetchedResultsController.sections?[section] {
      return sectionInfo.numberOfObjects
    }
    return 0
  }

  func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
    var onceToken = dispatch_once_t()
    dispatch_once(&onceToken) {
      tableView.registerNib(UINib(nibName: "EntryTableViewCell",
        bundle: NSBundle.mainBundle()), forCellReuseIdentifier: "entryCell")
    }
    let cell = tableView.dequeueReusableCellWithIdentifier("entryCell", forIndexPath: indexPath) as! EntryTableViewCell
    configureCell(cell, atIndexPath: indexPath)
    return cell
  }

  func longPress(gesture: UILongPressGestureRecognizer) {
    let loc = gesture.locationInView(tableView.superview)
    let y = loc.y
    if gesture.state == .Began {
      let cell = gesture.view as! EntryTableViewCell
      mergingCell = MergingCellImageView(image: imageWithView(cell))
      mergingCell.cell = cell
      mergingCell.alpha = 0.75
      mergingCell.center.y = y
      tableView.superview!.addSubview(mergingCell)
      cell.dragging = true
    }
    else if gesture.state == .Changed {
      pushScrollView(loc)
      checkMergeability(gesture.locationInView(tableView))
    }
    else if gesture.state == .Ended {
      mergingCell.removeFromSuperview()

      if let cellToKeep = cellAtPoint(gesture.locationInView(tableView)), cellToMerge = mergingCell.cell {
        let entryToKeep = fetchedResultsController.objectAtIndexPath(tableView.indexPathForCell(cellToKeep)!) as! Entry
        let entryToMerge = fetchedResultsController.objectAtIndexPath(tableView.indexPathForCell(cellToMerge)!) as! Entry
        if entryToKeep != entryToMerge {
          entryToMerge.archived = true
          entryToKeep.duration = entryToKeep.duration.integerValue + entryToMerge.duration.integerValue
          entryToKeep.syncStatus = .Changed
          entryToMerge.syncStatus = .Changed
          sync()
        }
      }

      (mergingCell.cell as? EntryTableViewCell)?.dragging = false
      NSNotificationCenter.defaultCenter().postNotificationName(EntryBecameMergeableNotification, object: nil)
    }
  }

  func checkMergeability(point: CGPoint) {
    if let mergableCell = cellAtPoint(point) {
      if mergableCell != mergingCell.cell {
        mergableCell.mergeable = true
      }
    } else {
      NSNotificationCenter.defaultCenter().postNotificationName(EntryBecameMergeableNotification, object: nil)
    }
  }

  func cellAtPoint(point: CGPoint) -> EntryTableViewCell? {
    if let indexPath = tableView.indexPathForRowAtPoint(point) {
      return tableView.cellForRowAtIndexPath(indexPath) as? EntryTableViewCell
    }
    return nil
  }

  func pushScrollView(point: CGPoint) {
    mergingCell.center.y = point.y
    var offset: CGPoint?
    let offsetY = tableView.contentOffset.y
    let topY = CGRectGetMinY(mergingCell.frame)
    let bottomY = CGRectGetMaxY(mergingCell.frame)

    if topY <= tableView.frame.origin.y && offsetY > 0 {
      let dy = tableView.frame.origin.y - topY
      offset = CGPointMake(tableView.contentOffset.x, max(0, offsetY - dy))
    }
    if bottomY >= CGRectGetMaxY(tableView.frame) &&
      offsetY < tableView.contentSize.height - tableView.frame.size.height {
      let dy = bottomY - CGRectGetMaxY(tableView.frame)
      offset = CGPointMake(tableView.contentOffset.x, offsetY + dy)
    }
    if let offset = offset {
      tableView.setContentOffset(offset, animated: true)
    }
  }

}

// MARK: - Fetched results controller delegate
extension EntriesViewController: NSFetchedResultsControllerDelegate {

  func controllerWillChangeContent(controller: NSFetchedResultsController) {
    tableView.beginUpdates()
  }

  func controllerDidChangeContent(controller: NSFetchedResultsController) {
    tableView.endUpdates()
    refreshControl.endRefreshing()
    setDayTotal()
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
        let cell = tableView.cellForRowAtIndexPath(indexPath!)!
        tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Automatic)
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

// MARK: - TimerController delegate
extension EntriesViewController: TimerControllerDelegate {

  func lastEntryEndedAtDidUpdate(lastUpdatedAt: NSDate?) {
    clockInOutButton.title = timerController.clockedIn ? "Clock out" : "Clock in"
    setDayTotal()
  }

}

// MARK: - Duration bar button item delegate
extension EntriesViewController: DurationBarButtonItemDelegate {

  func durationBarButtonItemMinuteUpdate() {
    setDayTotal()
  }

}

class MergingCellImageView: UIImageView {

  var cell: UITableViewCell?

}

// Utils

func imageWithView(view: UIView) -> UIImage {
  UIGraphicsBeginImageContextWithOptions(view.bounds.size, view.opaque, 0.0)
  view.layer.renderInContext(UIGraphicsGetCurrentContext())
  let image = UIGraphicsGetImageFromCurrentImageContext()
  UIGraphicsEndImageContext()
  return image
}
//
//  PersistenceController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData

class PersistenceController: NSObject {

  typealias InitCallbackBlock = () -> Void

  var managedObjectContext: NSManagedObjectContext!
  private var privateContext: NSManagedObjectContext!
  private var initCallback: InitCallbackBlock

  init(callback: InitCallbackBlock) {
    initCallback = callback
    super.init()
    initializeCoreData()
  }

  func save() {
    if !privateContext.hasChanges && !managedObjectContext.hasChanges {
      return
    }
    managedObjectContext.performBlockAndWait {
      var error: NSError?
      if !self.managedObjectContext.save(&error) {
        println("failed to save main context: \(error)")
      }
      self.privateContext.performBlock {
        var privateError: NSError?
        if !self.privateContext.save(&privateError) {
          println("failed to save private context: \(error)")
        }
      }
    }
  }

  private func initializeCoreData() {
    let modelURL = NSBundle.mainBundle().URLForResource("Data", withExtension: "momd")
    let mom = NSManagedObjectModel(contentsOfURL: modelURL!)
    let coordinator = NSPersistentStoreCoordinator(managedObjectModel: mom!)

    managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)

    privateContext = NSManagedObjectContext(concurrencyType: .PrivateQueueConcurrencyType)
    privateContext.persistentStoreCoordinator = coordinator
    managedObjectContext.parentContext = privateContext

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0)) {
      let psc = self.privateContext.persistentStoreCoordinator
      let options: [NSObject: AnyObject] = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true,
        NSSQLitePragmasOption: ["journal_mode": "DELETE"]
      ]
      let fileManager = NSFileManager.defaultManager()
      let documentsURL: NSURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).last as! NSURL
      let storeURL = documentsURL.URLByAppendingPathComponent("DataModel.sqlite")

      var error: NSError?
      psc!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: storeURL, options: options, error: &error)

      dispatch_async(dispatch_get_main_queue()) {
        self.initCallback()
      }
    }
  }

}

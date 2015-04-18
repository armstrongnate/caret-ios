//
//  CoreDataTestCase.swift
//  Caret
//
//  Created by Nate Armstrong on 4/17/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import XCTest
import CoreData

class CoreDataTestCase: XCTestCase {

  lazy var managedObjectModel: NSManagedObjectModel = {
    let modelURL = NSBundle.mainBundle().URLForResource("Data", withExtension: "momd")!
    return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

  lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
    var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
    var error: NSError? = nil
    var failureReason = "There was an error creating or loading the application’s saved data."
    if coordinator!.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil, error: &error) == nil {
      coordinator = nil
      let key = NSString(string: "Failed to initialize the application's saved data")
      let options: [NSObject: AnyObject] = [
        NSMigratePersistentStoresAutomaticallyOption: true,
        NSInferMappingModelAutomaticallyOption: true,
        NSSQLitePragmasOption: ["journal_mode": "DELETE"]
      ]
      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: options)
      NSLog("Unresolved error \(error), \(error!.userInfo)")
      abort()
    }

    return coordinator
    }()

  lazy var managedObjectContext: NSManagedObjectContext? = {
    let coordinator = self.persistentStoreCoordinator
    if coordinator == nil {
      return nil
    }
    var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedObjectContext.persistentStoreCoordinator = coordinator
    return managedObjectContext
    }()

  override func setUp() {

  }

  override func tearDown() {
    managedObjectContext = nil
  }

}

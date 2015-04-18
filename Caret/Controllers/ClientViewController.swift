//
//  ClientViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/15/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreData

class ClientViewController: UITableViewController {

  var client: Client!
  var context: NSManagedObjectContext!
  var syncController: SyncController!

  @IBOutlet weak var nameTextField: UITextField!

  override func viewDidLoad() {
    super.viewDidLoad()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func save(sender: AnyObject) {
    client.name = nameTextField.text
    client.hourly_rate = 85
    client.syncStatus = .Changed
    client.archived = false
    var error: NSError?
    if context.save(&error) {
      performSegueWithIdentifier("unwindFromSaveClient", sender: self)
      syncController.sync(["clients"])
    }
  }

}

//
//  SettingsController.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

  required init(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    setupTabBarItem("settings")
  }

  override func viewDidLoad() {
    super.viewDidLoad()

    // Do any additional setup after loading the view.
  }

}

//
//  Utilities.swift
//  Caret
//
//  Created by Nate Armstrong on 4/29/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import Foundation

func showSimpleAlertWithTitle(title: String!, #message: String, #viewController: UIViewController) {
  let alert = UIAlertController(title: title, message: message, preferredStyle: .Alert)
  let action = UIAlertAction(title: "OK", style: .Cancel, handler: nil)
  alert.addAction(action)
  viewController.presentViewController(alert, animated: true, completion: nil)
}

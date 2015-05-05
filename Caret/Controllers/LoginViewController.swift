//
//  LoginViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/30/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

protocol LoginViewControllerDelegate {

  func loginViewController(controller: LoginViewController, didLoginAsUser user: User)

}

class LoginViewController: UIViewController {

  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  @IBOutlet weak var submitButton: UIButton!
  @IBOutlet weak var centerYConstraint: NSLayoutConstraint!
  @IBOutlet weak var contentView: UIView!

  let submitButtonBorderColor = UIColor(red: 216.0/255.0, green: 72.0/255.0, blue: 16.0/255.0, alpha: 1.0).CGColor

  var delegate: LoginViewControllerDelegate?

  override func viewDidLoad() {
    super.viewDidLoad()

    view.backgroundColor = UIColor(white: 241.0/255.0, alpha: 1.0)

    submitButton.clipsToBounds = false
    submitButton.layer.cornerRadius = 5.0
    submitButton.layer.borderWidth = 1.0
    submitButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
    setButtonEnabled(true)

    // keyboard events
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func logIn() {
    if submitButton.enabled {
      setButtonEnabled(false)
      view.makeToastActivity()
      authenticate()
    }
  }

  func keyboardWillShow(notification: NSNotification) {
    if let kbRect = notification.userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue() {
      if centerYConstraint.constant == 0 {
        let move = (CGRectGetMaxY(contentView.frame) - (CGRectGetHeight(view.frame) - CGRectGetHeight(kbRect)))
        let padding: CGFloat = 30
        centerYConstraint.constant = move + padding
      }
    }
  }

  func keyboardWillHide(notification: NSNotification) {
    centerYConstraint.constant = 0
  }

  func authenticate() {
    let params = [
      "email": emailTextField.text,
      "password": passwordTextField.text
    ]
    Alamofire.request(.GET, "\(kApiURL)/users/authenticate", parameters: params)
      .responseJSON { (_, _, json, error) in
        self.view.hideToastActivity()
        self.setButtonEnabled(true)
        self.passwordTextField.text = ""
        if error == nil {
          let user = User(json: JSON(json!))
          User.current = user
          self.delegate?.loginViewController(self, didLoginAsUser: user)
        } else {
          showSimpleAlertWithTitle("Sign in failed", message: "Please try again.", viewController: self)
        }
    }
  }

  func setButtonEnabled(enabled: Bool) {
    submitButton.enabled = enabled
    submitButton.backgroundColor = enabled ? UIColor.secondaryColor() : UIColor.lightGrayColor()
    submitButton.layer.borderColor = enabled ? submitButtonBorderColor : UIColor.lightGrayColor().CGColor
  }

}

extension LoginViewController: UITextFieldDelegate {

  func textFieldShouldReturn(textField: UITextField) -> Bool {
    if textField == emailTextField {
      passwordTextField.becomeFirstResponder()
    } else if textField == passwordTextField {
      logIn()
    }
    return true
  }

}

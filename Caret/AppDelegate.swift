//
//  AppDelegate.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Custom nav bar color
    let navigationBarAppearance = UINavigationBar.appearance()
    navigationBarAppearance.tintColor = UIColor.secondaryColor()
    navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.secondaryColor()]

    let toolbarAppearance = UIToolbar.appearance()
    toolbarAppearance.tintColor = UIColor.secondaryColor()

    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    let dashboard = DashboardViewController(nibName: "DashboardViewController", bundle: nil)
    let nav = UINavigationController(rootViewController: dashboard)
    nav.toolbarHidden = false
    nav.delegate = self

    window!.rootViewController = nav
    window!.makeKeyAndVisible()

    return true
  }

  func applicationWillResignActive(application: UIApplication) {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
  }

  func applicationDidEnterBackground(application: UIApplication) {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
  }

}

extension AppDelegate: UINavigationControllerDelegate {

  func navigationController(navigationController: UINavigationController,
    willShowViewController viewController: UIViewController,
    animated: Bool) {
    let btn = UIBarButtonItem(title: "Clock in", style: .Plain, target: self, action: "")
    let btn2 = UIBarButtonItem(title: "00:00:00", style: .Plain, target: self, action: "")

    // if clocked out
    btn2.tintColor = UIColor.grayColor()

    let flex = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    viewController.setToolbarItems([btn, flex, btn2], animated: false)
  }

}

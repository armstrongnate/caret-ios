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
  var persistenceController: PersistenceController!
  var syncController: SyncController!


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    // Custom nav bar color
    let navigationBarAppearance = UINavigationBar.appearance()
    navigationBarAppearance.tintColor = UIColor.secondaryColor()
    navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.secondaryColor()]

    let toolbarAppearance = UIToolbar.appearance()
    toolbarAppearance.tintColor = UIColor.secondaryColor()

    persistenceController = PersistenceController(callback: sync)

    return true
  }

  func sync() {
    syncController = SyncController(context: persistenceController.managedObjectContext, callback: showDashboard)
    syncController.sync(["clients", "projects"])
  }

  func showDashboard() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)

    let dashboard = DashboardViewController(nibName: "DashboardViewController", bundle: nil)
    dashboard.persistenceController = persistenceController
    let nav = UINavigationController(rootViewController: dashboard)
    nav.toolbarHidden = false
    nav.delegate = self

    window!.rootViewController = nav
    window!.makeKeyAndVisible()
  }

  func applicationWillResignActive(application: UIApplication) {
    persistenceController.save()
  }

  func applicationDidEnterBackground(application: UIApplication) {
    persistenceController.save()
  }

  func applicationWillEnterForeground(application: UIApplication) {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
  }

  func applicationDidBecomeActive(application: UIApplication) {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
  }

  func applicationWillTerminate(application: UIApplication) {
    persistenceController.save()
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

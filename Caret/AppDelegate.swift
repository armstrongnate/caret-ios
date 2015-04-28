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
  var timerController: TimerController!


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    persistenceController = PersistenceController(callback: sync)
    timerController = TimerController(userID: 6)

    // Custom nav bar color
    let navigationBarAppearance = UINavigationBar.appearance()
    navigationBarAppearance.tintColor = UIColor.secondaryColor()
    navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.secondaryColor()]

    let toolbarAppearance = UIToolbar.appearance()
    toolbarAppearance.tintColor = UIColor.secondaryColor()

    return true
  }

  func sync() {
    syncController = SyncController(context: persistenceController.managedObjectContext, callback: showDashboard)
    syncController.sync(["clients", "projects", "entries"])
  }

  func showDashboard() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("entries") as! EntriesViewController
    vc.context = persistenceController.managedObjectContext
    vc.timerController = timerController
    let nav = UINavigationController(rootViewController: vc)
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

  func application(application: UIApplication, handleWatchKitExtensionRequest userInfo: [NSObject : AnyObject]?, reply: (([NSObject : AnyObject]!) -> Void)!) {
    if let message = userInfo?["watch"] as? String {
      switch message {
      case "update":
        timerController.update()
      case "clock_in":
        timerController.clockIn()
      case "clock_out":
        timerController.clockOut()
      default:
        return
      }
    }
    reply([:])
  }

}

extension AppDelegate: UINavigationControllerDelegate {

}

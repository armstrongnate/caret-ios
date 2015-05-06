//
//  AppDelegate.swift
//  Caret
//
//  Created by Nate Armstrong on 2/21/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import CoreLocation
import MMWormhole

let kNotificationCategoryClockIn = "clockInCategory"
let kNotificationCategoryClockOut = "clockOutCategory"
let kNotificationActionClockIn = "clockInAction"
let kNotificationActionClockOut = "clockOutAction"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?
  var persistenceController: PersistenceController!
  var timerController: TimerController!
  let locationManager = CLLocationManager()
  var notificationClockEvent: ClockEvent?
  var wormhole: MMWormhole!

  var entriesViewController: EntriesViewController {
    let storyboard = UIStoryboard(name: "Main", bundle: nil)
    let vc = storyboard.instantiateViewControllerWithIdentifier("entries") as! EntriesViewController
    vc.context = self.persistenceController.managedObjectContext
    vc.timerController = self.timerController
    return vc
  }
  var loginViewController: LoginViewController {
    let vc = LoginViewController(nibName: "LoginViewController", bundle: nil)
    vc.delegate = self
    return vc
  }


  func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
    persistenceController = PersistenceController(callback: loadUI)
    locationManager.delegate = self

    // Custom nav bar color
    let navigationBarAppearance = UINavigationBar.appearance()
    navigationBarAppearance.tintColor = UIColor.secondaryColor()
    navigationBarAppearance.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.secondaryColor()]

    let toolbarAppearance = UIToolbar.appearance()
    toolbarAppearance.tintColor = UIColor.secondaryColor()

    registerForNotifications()

    return true
  }

  func loadUI() {
    window = UIWindow(frame: UIScreen.mainScreen().bounds)
    if authenticated() {
      timerController = TimerController(userID: User.current!.userID)
      let nav = UINavigationController(rootViewController: entriesViewController)
      window!.rootViewController = nav
    } else {
      window!.rootViewController = loginViewController
    }
    window!.makeKeyAndVisible()
  }

  func registerForNotifications() {
    // clock in
    let clockIn = UIMutableUserNotificationAction()
    clockIn.identifier = kNotificationActionClockIn
    clockIn.title = "Clock in"
    clockIn.activationMode = UIUserNotificationActivationMode.Background
    clockIn.authenticationRequired = true
    clockIn.destructive = false

    let clockInCategory = UIMutableUserNotificationCategory()
    clockInCategory.identifier = kNotificationCategoryClockIn

    clockInCategory.setActions([clockIn],
    forContext: UIUserNotificationActionContext.Default)

    clockInCategory.setActions([clockIn],
    forContext: UIUserNotificationActionContext.Minimal)

    // clock out
    let clockOut = UIMutableUserNotificationAction()
    clockOut.identifier = kNotificationActionClockOut
    clockOut.title = "Clock out"
    clockOut.activationMode = UIUserNotificationActivationMode.Background
    clockOut.authenticationRequired = true
    clockOut.destructive = false

    let clockOutCategory = UIMutableUserNotificationCategory()
    clockOutCategory.identifier = kNotificationCategoryClockOut

    clockOutCategory.setActions([clockOut],
    forContext: UIUserNotificationActionContext.Default)

    clockOutCategory.setActions([clockOut],
    forContext: UIUserNotificationActionContext.Minimal)

    let types = UIUserNotificationType.Alert | UIUserNotificationType.Sound
    let settings = UIUserNotificationSettings(forTypes: types, categories: Set([clockInCategory, clockOutCategory]))
    UIApplication.sharedApplication().registerUserNotificationSettings(settings)
    UIApplication.sharedApplication().cancelAllLocalNotifications()

    // setup wormhole for notifications
    let groupIdentifier = "group.com.natearmstrong.caret"
    let messageIdentifier = "lastEntryEndedAt"
    wormhole = MMWormhole(applicationGroupIdentifier: groupIdentifier, optionalDirectory: "wormhole")
    wormhole.listenForMessageWithIdentifier(messageIdentifier, listener: wormholeCallback)
  }

  private func wormholeCallback(messageObject: AnyObject!) {
    if let clockEvent = notificationClockEvent {
      if clockEvent == .In && !timerController.clockedIn {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        presentNotificationForClockEvent(.In)
      } else if clockEvent == .Out && timerController.clockedIn {
        UIApplication.sharedApplication().cancelAllLocalNotifications()
        presentNotificationForClockEvent(.Out)
      }

      self.notificationClockEvent = nil
    }
  }

  private func presentNotificationForClockEvent(clockEvent: ClockEvent) {
    let message = clockEvent == .In ? "Shall we begin?" : "Did you mean to clock out?"
    if UIApplication.sharedApplication().applicationState != .Active {
      var notification = UILocalNotification()
      notification.alertBody = message
      notification.soundName = UILocalNotificationDefaultSoundName
      notification.category = clockEvent == .In ? kNotificationCategoryClockIn : kNotificationCategoryClockOut
      UIApplication.sharedApplication().presentLocalNotificationNow(notification)
    }
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

  func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
    if notification.category == kNotificationCategoryClockIn {
      if identifier == kNotificationActionClockIn {
        timerController.clockIn()
      }
    } else if notification.category == kNotificationCategoryClockOut {
      if identifier == kNotificationActionClockOut {
        timerController.clockOut()
      }
    }
    completionHandler()
  }

}

extension AppDelegate: CLLocationManagerDelegate {

  func handleRegionEvent(region: CLRegion!, _ clockEvent: ClockEvent) {
    self.notificationClockEvent = clockEvent
    timerController.update() // triggers wormholeCallback
  }

  func georeminderForRegionIdentifier(identifier: String) -> Georeminder? {
    if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
      for savedItem in savedItems {
        if let georeminder = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Georeminder {
          if georeminder.identifier == identifier {
            return georeminder
          }
        }
      }
    }
    return nil
  }

  func locationManager(manager: CLLocationManager!, didEnterRegion region: CLRegion!) {
    if region is CLCircularRegion {
      if let georeminder = georeminderForRegionIdentifier(region.identifier) {
        if let onEntry = georeminder.onEntry {
          handleRegionEvent(region, onEntry)
        }
      }
    }
  }

  func locationManager(manager: CLLocationManager!, didExitRegion region: CLRegion!) {
    if region is CLCircularRegion {
      if let georeminder = georeminderForRegionIdentifier(region.identifier) {
        if let onExit = georeminder.onExit {
          handleRegionEvent(region, onExit)
        }
      }
    }
  }

}

extension AppDelegate: LoginViewControllerDelegate {

  func loginViewController(controller: LoginViewController, didLoginAsUser user: User) {
    timerController = TimerController(userID: user.userID)
    let nav = UINavigationController(rootViewController: entriesViewController)
    window!.rootViewController = nav
  }

}

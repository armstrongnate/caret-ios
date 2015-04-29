//
//  GeoremindersViewController.swift
//  Caret
//
//  Created by Nate Armstrong on 4/28/15.
//  Copyright (c) 2015 Nate Armstrong. All rights reserved.
//

import UIKit
import MapKit

let kSavedItemsKey = "savedItems"

class GeoremindersViewController: UIViewController {

  @IBOutlet weak var mapView: MKMapView!

  var georeminders = [Georeminder]()

  override func viewDidLoad() {
    super.viewDidLoad()

    loadAllGeoreminders()
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  @IBAction func unwindFromAddGeoreminder(segue: UIStoryboardSegue) {}

  override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    if segue.identifier == "addGeoreminder" {
      let controller = segue.destinationViewController.topViewController as! AddGeoreminderViewController
      controller.delegate = self
    }
  }

  func loadAllGeoreminders() {
    georeminders = []

    if let savedItems = NSUserDefaults.standardUserDefaults().arrayForKey(kSavedItemsKey) {
      for savedItem in savedItems {
        if let georeminder = NSKeyedUnarchiver.unarchiveObjectWithData(savedItem as! NSData) as? Georeminder {
          addGeoreminder(georeminder)
        }
      }
    }
  }

  func saveAllGeoreminders() {
    var items = NSMutableArray()
    for georeminder in georeminders {
      let item = NSKeyedArchiver.archivedDataWithRootObject(georeminder)
      items.addObject(item)
    }
    NSUserDefaults.standardUserDefaults().setObject(items, forKey: kSavedItemsKey)
    NSUserDefaults.standardUserDefaults().synchronize()
  }

}

// MARK: - AddGeoreminderViewControllerDelegate
extension GeoremindersViewController: AddGeoreminderViewControllerDelegate {

  func addGeoreminderController(controller: AddGeoreminderViewController, didAddCoordinate coordinate: CLLocationCoordinate2D, radius: Double, identifier: String, onEntry: ClockEvent?, onExit: ClockEvent?) {
    controller.dismissViewControllerAnimated(true, completion: nil)
    let georeminder = Georeminder(coordinate: coordinate, radius: radius, identifier: identifier, onEntry: onEntry, onExit: onExit)
    addGeoreminder(georeminder)
    saveAllGeoreminders()
  }

  func addGeoreminder(georeminder: Georeminder) {
    georeminders.append(georeminder)
    mapView.addAnnotation(georeminder)
    addRadiusOverlayForGeoreminder(georeminder)
  }

  func removeGeoreminder(georeminder: Georeminder) {
    if let indexInArray = find(georeminders, georeminder) {
      georeminders.removeAtIndex(indexInArray)
    }

    mapView.removeAnnotation(georeminder)
    removeRadiusOverlayForGeoreminder(georeminder)
  }

  func addRadiusOverlayForGeoreminder(georeminder: Georeminder) {
    mapView.addOverlay(MKCircle(centerCoordinate: georeminder.coordinate, radius: georeminder.radius))
  }

  func removeRadiusOverlayForGeoreminder(georeminder: Georeminder) {
    // Find exactly one overlay which has the same coordinates & radius to remove
    if let overlays = mapView?.overlays {
      for overlay in overlays {
        if let circleOverlay = overlay as? MKCircle {
          var coord = circleOverlay.coordinate
          if coord.latitude == georeminder.coordinate.latitude && coord.longitude == georeminder.coordinate.longitude && circleOverlay.radius == georeminder.radius {
            mapView?.removeOverlay(circleOverlay)
            break
          }
        }
      }
    }
  }

}

// MARK: - Map view delegate
extension GeoremindersViewController: MKMapViewDelegate {

  func mapView(mapView: MKMapView!, rendererForOverlay overlay: MKOverlay!) -> MKOverlayRenderer! {
    if overlay is MKCircle {
      return Georeminder.rendererForOverlay(overlay)
    }
    return nil
  }

  func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
    let identifier = "myGeoreminder"
    if annotation is Georeminder {
      var annotationView = mapView.dequeueReusableAnnotationViewWithIdentifier(identifier) as? MKPinAnnotationView
      if annotationView == nil {
        annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        annotationView?.canShowCallout = true
        var removeButton = UIButton.buttonWithType(.Custom) as! UIButton
        removeButton.frame = CGRect(x: 0, y: 0, width: 23, height: 23)
        removeButton.setImage(UIImage(named: "DeleteGeoreminder")!, forState: .Normal)
        annotationView?.leftCalloutAccessoryView = removeButton
      } else {
        annotationView?.annotation = annotation
      }
      return annotationView
    }
    return nil
  }

  func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
    // Delete georeminder
    var georeminder = view.annotation as! Georeminder
    removeGeoreminder(georeminder)
    saveAllGeoreminders()
  }

}


//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 11/30/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var bottomToolbar: UIToolbar!
    @IBOutlet weak var editBtn: UIBarButtonItem!
    
    // for animating view when edit is pressed
    @IBOutlet weak var mapViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var bottomToolbarBottomConstraint: NSLayoutConstraint!
    
    var managedContext: NSManagedObjectContext!
    
    var editingMap = false
    var editButtonAction = UIBarButtonItem()
    
    //var userAnnotations: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        editButtonAction = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBtnPressed))
        navigationItem.rightBarButtonItem = editButtonAction
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Load saved pins
        let pinFetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        do {
            let results = try managedContext.fetch(pinFetchRequest)
            loadSavedPins(pins: results)
        } catch let error as NSError{
            print("Cound not fetch \(error), \(error.userInfo)")
        }
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
    
        let reuseId = "pin"
        var pinView: MKPinAnnotationView
        
        if let dequeuedView = mapView.dequeueReusableAnnotationView(withIdentifier: reuseId) as? MKPinAnnotationView {
            // A dequeued view is available
            dequeuedView.annotation = annotation
            pinView = dequeuedView
        } else {
            // Create new annotaion
            pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: reuseId)
            pinView.animatesDrop = true
            pinView.pinTintColor = UIColor.purple
            pinView.canShowCallout = false
        }
        return pinView
    }
      
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        if editingMap {
            deletePin(pin: view)
        } else {
            // Goto PhotoCollectionViewController
            guard let photoViewController = UIStoryboard(name:"Main", bundle:nil).instantiateViewController(withIdentifier: "PhotoCollectionViewController") as? PhotoCollectionViewController else {
                print("Could not instantiate PhotoCollectionViewController")
                return
            }
            photoViewController.pinView = view
            self.navigationController?.pushViewController(photoViewController, animated:true)
        }

    }
    
    func deletePin(pin: MKAnnotationView) {
        
        guard let lat = pin.annotation?.coordinate.latitude, let lon = pin.annotation?.coordinate.longitude else {
            print("Error getting lat/lon from pin")
            return
        }
        
        // search for match
        // Core data rounds the location so we will search between two values using a predicate
        let precision = 0.000001
        let pinFetchRequest = NSFetchRequest<Pin>(entityName: "Pin")
        pinFetchRequest.predicate = NSPredicate(format: "(%K BETWEEN {\(lat - precision), \(lat + precision) }) AND (%K BETWEEN {\(lon - precision), \(lon + precision) })", #keyPath(Pin.latitude), #keyPath(Pin.longitude))
        
        do {
            let results = try managedContext.fetch(pinFetchRequest)
            print(results.count)
            print("Searching for \(lat)")
            // delete the first result (in case there was more than one match)
            
            if results.count > 0 {
                managedContext.delete(results.first!)
                do {
                    try managedContext.save()
                    // Also delete pin from mapview
                    mapView.removeAnnotation(pin.annotation!)
                } catch let error as NSError {
                    print("Saving error: \(error), description: \(error.userInfo)")
                }
            }
            
        } catch let error as NSError{
            print("Cound not fetch \(error), \(error.userInfo)")
            return
        }
    }
    
    @IBAction func addPin(_ sender: UILongPressGestureRecognizer) {
        
        // Only create one pin on longpress
        if sender.state == .began {
            let touchLocation = sender.location(in: mapView)
            // convert touchpont to CLLocationCoordinate2D for annotation use
            let coords = mapView.convert(touchLocation, toCoordinateFrom: mapView)
            let newAnnotation = MKPointAnnotation()
            newAnnotation.coordinate = coords
            mapView.addAnnotation(newAnnotation)
            savePin(coords: coords)
        }
    }
    
    // Add saved pins to map
    func loadSavedPins(pins: [Pin]) {
        //print(pins)
        for pin in pins {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = pin.latitude
            annotation.coordinate.longitude = pin.longitude
            mapView.addAnnotation(annotation)
        }
    }
   
    // Save pin to core data
    func savePin(coords: CLLocationCoordinate2D) {
        
        let pinEntity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        let pin = Pin(entity: pinEntity, insertInto: managedContext)
        pin.latitude = coords.latitude
        pin.longitude = coords.longitude
        
        //let fetch = NSFetchRequest<Pin>(entityName: "Pin")
        //let count = try! managedContext.count(for: fetch)

        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save new pin. \(error), \(error.userInfo)")
        }
    }
    
    func editBtnPressed() {
        
        if !editingMap {
            editingMap = true
            navigationItem.rightBarButtonItem?.title = "Done"
            navigationItem.rightBarButtonItem?.style = .done
            mapViewBottomConstraint.constant += bottomToolbar.frame.height
            bottomToolbarBottomConstraint.constant += bottomToolbar.frame.height
            UIView.animate(withDuration: 0.4 , animations: {
                self.view.layoutIfNeeded()
            })
        } else {
            editingMap = false
            navigationItem.rightBarButtonItem?.title = "Edit"
            navigationItem.rightBarButtonItem?.style = .plain
            mapViewBottomConstraint.constant -= bottomToolbar.frame.height
            bottomToolbarBottomConstraint.constant -= bottomToolbar.frame.height
            UIView.animate(withDuration: 0.4 , animations: {
                self.view.layoutIfNeeded()
            })
        }
    }
}

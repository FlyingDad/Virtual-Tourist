
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
    
    var editingMap = false
    var editButtonAction = UIBarButtonItem()
    
    var userAnnotations: [NSManagedObject] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        editButtonAction = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(editBtnPressed))
        navigationItem.rightBarButtonItem = editButtonAction
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Pin")
        
        do {
            userAnnotations = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        print(userAnnotations.count)
        loadSavedAnnotations()
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
       print("Selected pin")
       // goto collectionview from here
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
    
    func loadSavedAnnotations() {
        //print("Loaded user annotations count: \(userAnnotations.count)")
        for annotationObject in userAnnotations {
            let annotation = MKPointAnnotation()
            annotation.coordinate.latitude = annotationObject.value(forKey: "latitude") as! CLLocationDegrees
            annotation.coordinate.longitude = annotationObject.value(forKey: "longitude") as! CLLocationDegrees
            mapView.addAnnotation(annotation)
            //print("Loaded annotation: \(annotation.coordinate)")
        }
        //print("Added annotaions count: \(mapView.annotations.count)")
    }
   
    // Save pin to core data
    func savePin(coords: CLLocationCoordinate2D) {
        
        guard let appDelegate =  UIApplication.shared.delegate as? AppDelegate else {
            return
        }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let entity = NSEntityDescription.entity(forEntityName: "Pin", in: managedContext)!
        let pin = NSManagedObject(entity: entity, insertInto: managedContext)
        pin.setValue(coords.latitude, forKey: "latitude")
        pin.setValue(coords.longitude, forKey: "longitude")
        
        do {
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
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

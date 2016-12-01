//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 11/30/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    var userAnnotations = [MKPointAnnotation]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
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
            // add to annotaions array for persistence
            userAnnotations.append(newAnnotation)
            //print(userAnnotations.count)
        }
    }

}

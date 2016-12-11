//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 11/30/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit
import MapKit

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate {

    @IBOutlet weak var mapView: MKMapView!
    
    let Client = FlickrClient()
    // need pin info so we can get lat long and save placeId 
    var pinView = MKAnnotationView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        //Client.getLocationId(lat: 11.1111, lon: 22.2222)
        setupMapView(view: pinView)
    }
    
    // Purple pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pinView: MKPinAnnotationView
        pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pinView.animatesDrop = true
        pinView.pinTintColor = UIColor.purple
        pinView.canShowCallout = false
        
        return pinView
    }

    func setupMapView(view: MKAnnotationView) {
        mapView.isScrollEnabled = false
        mapView.addAnnotation(view.annotation!)
        let span = MKCoordinateSpan(latitudeDelta: 0.04225, longitudeDelta: 0.04225)
        let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    @IBAction func doneBtnPressed(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
}

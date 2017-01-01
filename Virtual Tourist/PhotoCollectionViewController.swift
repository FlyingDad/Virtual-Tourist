//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 11/30/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoCollectionViewController: UIViewController, MKMapViewDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    let client = FlickrClient()
    var managedContext: NSManagedObjectContext!
    var pinView = MKAnnotationView()
    var pin: Pin!
    var photosArray = [Photo!]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView(view: pinView)
        collectionView.delegate = self
        collectionView.dataSource = self
        // print("Finally made it: \(pin.locationId)")
        getPhotosForLocation(locationId: pin.locationId!)
    }
    
    // Layout the collection view - from Color Collection by Jason
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // Layout the collection view so that cells take up 1/3 of the width,
        // with no space in-between.
        let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        layout.minimumLineSpacing = 0
        layout.minimumInteritemSpacing = 0
        let width = floor(self.collectionView.frame.size.width/3)
        layout.itemSize = CGSize(width: width, height: width)
        collectionView.collectionViewLayout = layout
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 6
    }
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        return cell
    }
    
    
    // Purple pin
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        
        var pin: MKPinAnnotationView
        pin = MKPinAnnotationView(annotation: annotation, reuseIdentifier: nil)
        pin.animatesDrop = true
        pin.pinTintColor = UIColor.purple
        pin.canShowCallout = false
        
        return pin
    }

    func setupMapView(view: MKAnnotationView) {
        mapView.isScrollEnabled = false
        mapView.addAnnotation(view.annotation!)
        let span = MKCoordinateSpan(latitudeDelta: 0.04225, longitudeDelta: 0.04225)
        let region = MKCoordinateRegion(center: (view.annotation?.coordinate)!, span: span)
        mapView.setRegion(region, animated: true)
    }
    
    func getPhotosForLocation(locationId: String) {
        //Returns data for photos at location (# of photos, array of photos, etc)
        client.getPhotoDataForLocationId(locationId: pin.locationId!) { (data, error) in
            print("get photo return")
            guard (error == nil) else {
                // Display alert?
                return
            }
            
            print(data?["total"])
        }
    }
    

    @IBAction func doneBtnPressed(_ sender: Any) {
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
}

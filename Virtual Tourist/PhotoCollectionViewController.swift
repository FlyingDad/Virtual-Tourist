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
    @IBOutlet weak var toolBarButton: UIBarButtonItem!
    
    let client = FlickrClient()
    var managedContext: NSManagedObjectContext!
    var pinView = MKAnnotationView()
    var pin: Pin!
    var photosArray = [Photo!]()
    var fetchedResultsController: NSFetchedResultsController<NSFetchRequestResult>!
    
    var selectedCellIndexes = [IndexPath]()
    
    var insertedIndexPaths: [IndexPath]!
    var deletedIndexPaths: [IndexPath]!
    //var updatedIndexPaths: [IndexPath]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mapView.delegate = self
        setupMapView(view: pinView)
        collectionView.delegate = self
        collectionView.dataSource = self
        toolBarButton.title = "New Collection"
        if loadPhotos().isEmpty {
            getPhotoUrlsForLocation(locationId: pin.locationId!)
        }
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
    
    func configureCell(_ cell: PhotoCollectionViewCell, atIndexPath indexPath: IndexPath) {
        
        print("Configuring cell")
        if let _ = selectedCellIndexes.index(of: indexPath) {
            cell.alpha = 1.0
        } else {
            cell.alpha = 0.5
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //return 21
        return fetchedResultsController.sections![section].numberOfObjects
    }

    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoCell", for: indexPath) as! PhotoCollectionViewCell
        cell.activityIndicator.startAnimating()
        let photo = fetchedResultsController.object(at: indexPath) as! Photo
        
        client.downloadPhoto(urlString: photo.url!) { (imageData, error) in
            guard (error == nil) else {
                print("Error downloading photo for cell: \(error!.localizedDescription)")
                return
            }
            guard let image = UIImage(data: imageData!) else {
                return
            }
            
            DispatchQueue.main.async {
                photo.data = imageData as NSData?
                do {
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Could not save photo data. \(error), \(error.userInfo)")
                }
                cell.photo.image = image
                cell.activityIndicator.stopAnimating()
            }
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("Selected cell")
        let cell = collectionView.cellForItem(at: indexPath) as! PhotoCollectionViewCell
        self.configureCell(cell, atIndexPath: indexPath)
        
        if let cellIndex = selectedCellIndexes.index(of: indexPath) {
            selectedCellIndexes.remove(at: cellIndex)
        } else {
            selectedCellIndexes.append(indexPath)
        }
        
        if selectedCellIndexes.isEmpty {
            toolBarButton.title = "New Collection"
        } else {
            toolBarButton.title = "Delete Selected Items"
        }
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
    
    func getPhotoUrlsForLocation(locationId: String) {
        
        client.getPhotoUrlsForLocationId(locationId: pin.locationId!) { (data, error) in
            print("get photo return")
            guard (error == nil) else {
                // Display alert?
                print("Error: \(error!.localizedDescription)")
                return
            }
            guard let photoUrls = data! as? NSArray else {
                return
            }
            
            if photoUrls.count == 0 {
                self.alertNoPhotos()
            }
            // Save the urls to each photo object
            DispatchQueue.main.async {
                
                do {
                    for eachUrl in photoUrls {
                        let photo = Photo(context: self.managedContext)
                        photo.pin = self.pin
                        photo.url = eachUrl as? String
                    }
                    try self.managedContext.save()
                    }catch let error as NSError {
                        print("Fetch error: \(error) description: \(error.userInfo)")
                    }
            }
        }
    }

    @IBAction func doneBtnPressed(_ sender: Any) {
        
        if let navController = self.navigationController {
            navController.popViewController(animated: true)
        }
    }
    
    @IBAction func deleteSelectedCells(_ sender: Any) {
        
        //If any cells are selected, delete them
        if !selectedCellIndexes.isEmpty {
            var photosToDelete = [Photo]()
            
            
            for eachCellSelected in selectedCellIndexes {
                photosToDelete.append(fetchedResultsController.object(at: eachCellSelected) as! Photo)
            }
            
            DispatchQueue.main.async {
                do {
                    for photo in photosToDelete {
                        self.managedContext.delete(photo)
                    }
                    try self.managedContext.save()
                }catch let error as NSError {
                    print("Fetch error: \(error) description: \(error.userInfo)")
                }
            }
        } else { // delete all photos for New Collection
            
            DispatchQueue.main.async {
                do {
                    let allPhotos =  self.fetchedResultsController.fetchedObjects as! [Photo]
                    for eachPhoto in allPhotos {
                        self.managedContext.delete(eachPhoto)
                    }
                    try self.managedContext.save()
                } catch let error as NSError {
                    print("Fetch error: \(error) description: \(error.userInfo)")
                }
                self.getPhotoUrlsForLocation(locationId: self.pin.locationId!)
            }
        }
        toolBarButton.title = "New Collection"
        selectedCellIndexes = [IndexPath]()
    }
    
// End of Class
}

extension PhotoCollectionViewController: NSFetchedResultsControllerDelegate {
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("In controller will change")
        insertedIndexPaths = [IndexPath]()
        deletedIndexPaths = [IndexPath]()
        //updatedIndexPaths = [IndexPath]()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        print("In controller did change object")
        switch type {
            
        case .insert:
            print("Insert an item")
            // Here we are noting that a new Color instance has been added to Core Data. We remember its index path
            // so that we can add a cell in "controllerDidChangeContent". Note that the "newIndexPath" parameter has
            // the index path that we want in this case
            insertedIndexPaths.append(newIndexPath!)
            break
        case .delete:
            print("Delete an item")
            // Here we are noting that a Color instance has been deleted from Core Data. We remember its index path
            // so that we can remove the corresponding cell in "controllerDidChangeContent". The "indexPath" parameter has
            // value that we want in this case.
            deletedIndexPaths.append(indexPath!)
            break
//        case .update:
//            print("Update an item.")
//            // We don't expect Color instances to change after they are created. But Core Data would
//            // notify us of changes if any occured. This can be useful if you want to respond to changes
//            // that come about after data is downloaded. For example, when an image is downloaded from
//            // Flickr in the Virtual Tourist app
//            updatedIndexPaths.append(indexPath!)
//            break
        case .move:
            print("Move an item. We don't expect to see this in this app.")
            break
        default:
            break
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        print("In controller did change")
        collectionView.performBatchUpdates({ 
            
            for indexPath in self.insertedIndexPaths {
                self.collectionView.insertItems(at: [indexPath])
            }
            
            for indexPath in self.deletedIndexPaths {
                self.collectionView.deleteItems(at: [indexPath])
            }
            
//            for indexPath in self.updatedIndexPaths {
//                self.collectionView.reloadItems(at: [indexPath])
//            }
        }, completion: nil)
    }
    
    
    func loadPhotos() -> [Photo] {
        
        var photos = [Photo]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
        fetchRequest.sortDescriptors = []
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedContext, sectionNameKeyPath: nil, cacheName: nil)
        
        fetchedResultsController.delegate = self
        
        do {
            try fetchedResultsController.performFetch()
            if let results = fetchedResultsController.fetchedObjects as? [Photo] {
                photos = results
            }
        } catch {
            print("Error fetching photos from core data")
        }
        return photos
    }
    
    func alertNoPhotos(){
        let alert = UIAlertController(title: "Notice", message: "No photos were found near this location.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: UIAlertActionStyle.default, handler: nil))
        DispatchQueue.main.async {
            self.present(alert, animated: true, completion: nil)
        }
        
    }
    
}

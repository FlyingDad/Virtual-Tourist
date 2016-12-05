//
//  PhotoCollectionViewController.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 11/30/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import UIKit

class PhotoCollectionViewController: UIViewController {

    let Client = FlickrClient()
    // need pin info so we can get lat long and save placeId 
    //var pin =
    
    override func viewDidLoad() {
        super.viewDidLoad()

        Client.getLocationId(lat: 11.1111, lon: 22.2222)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

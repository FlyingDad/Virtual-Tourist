//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 12/5/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation


class FlickrClient {
    
    
    func getLocationId(lat: Double, lon: Double, completionHandlerForGetLocationId: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let methodParameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.LatLonMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.Latitude: String(lat),
            FlickrConstants.FlickrParameterKeys.Longitude: String(lon),
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
        ]
        
        let urlString = FlickrConstants.Flickr.APIBaseUrl + escapedParameters(parameters: methodParameters)
        
        getDataTask(urlString: urlString) { (data, error) in
            
            guard (error == nil) else {
                completionHandlerForGetLocationId(nil, NSError(domain: "Get Location ID", code: 100, userInfo: nil))
                return
            }
            
            guard let status = data?[FlickrConstants.FlickrResponseKeys.Status] as? String, status == FlickrConstants.FlickrResponseValues.StatusOK else {
                completionHandlerForGetLocationId(nil, NSError(domain: "Get Location ID - status error", code: 200, userInfo: nil))
                return
            }
            
            /* GUARD: Is there a place in the result? */
            guard let places = data?[FlickrConstants.FlickrResponseKeys.PlacesResponse] as? [String:AnyObject],
                let place = places[FlickrConstants.FlickrResponseKeys.Place] as? [[String:AnyObject]] else {
                    completionHandlerForGetLocationId(nil, NSError(domain: "Get Location ID - no place found", code: 300, userInfo: nil))
                    return
            }
            
            // Get place Id
            guard let placeId = place[0][FlickrConstants.FlickrResponseKeys.PlaceId] as? String else {
                completionHandlerForGetLocationId(nil, NSError(domain: "Get Location ID - no place Id found", code: 400, userInfo: nil))
                return
            }
            completionHandlerForGetLocationId(placeId as AnyObject, nil)
        }
    }
    
    func getPhotoUrlsForLocationId(locationId: String, completionHandlerForGetPhotoDataForLocationId: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let methodParameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.photoSearchMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.PlaceId: locationId,
            FlickrConstants.FlickrParameterKeys.PerPage: FlickrConstants.FlickrParameterValues.PerPage,
            FlickrConstants.FlickrParameterKeys.Pages: self.randomPageGenerator(),
            FlickrConstants.FlickrParameterKeys.Extras: FlickrConstants.FlickrParameterValues.ExtraMediumUrl,
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback,
            "radius": "16"
        ]
        
        let urlString = FlickrConstants.Flickr.APIBaseUrl + escapedParameters(parameters: methodParameters)
        
        getDataTask(urlString: urlString) { (data, error) in
            
            guard (error == nil) else {
                completionHandlerForGetPhotoDataForLocationId(nil, NSError(domain: "Get Photo Data", code: 100, userInfo: nil))
                return
            }
            
            guard let status = data?[FlickrConstants.FlickrResponseKeys.Status] as? String, status == FlickrConstants.FlickrResponseValues.StatusOK else {
                completionHandlerForGetPhotoDataForLocationId(nil, NSError(domain: "Get Photo Data - status error", code: 200, userInfo: nil))
                return
            }

            /* GUARD: Are there photos in the result? */
            guard let photosDict = data?[FlickrConstants.FlickrResponseKeys.Photos] as? [String: AnyObject], let photosArray = photosDict[FlickrConstants.FlickrResponseKeys.Photo] as? [[String:AnyObject]] else {
                print("Not getting photosarray")
                completionHandlerForGetPhotoDataForLocationId(nil, NSError(domain: "Get Photo Data - no photos found", code: 300, userInfo: nil))
                    return
            }
            // Extract urls for each phot and put into array
            var photoUrls = [String]()
            for eachPhoto in photosArray {
                photoUrls.append((eachPhoto[FlickrConstants.FlickrParameterValues.ExtraMediumUrl] as? String)!)
            }
            completionHandlerForGetPhotoDataForLocationId(photoUrls as AnyObject, nil)
        }
    }
    
    func downloadPhoto(urlString: String, completionHandlerForDownloadPhoto: @escaping(_ result: Data?, _ error: NSError?) -> Void) {
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandlerForDownloadPhoto(nil, error! as NSError)
                return
            }
            completionHandlerForDownloadPhoto(data, nil)
        }
        task.resume()

    }
    
    // MARK: Data Task
    func getDataTask (urlString: String , completionHandlerForGetDataTask: @escaping (_ result: AnyObject? , _ error: NSError?) -> Void)
    {
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        let session = URLSession.shared
        //Create Task
        let task = session.dataTask(with: request) { (data, response, error) in
            
            guard (error == nil) else {
                completionHandlerForGetDataTask(nil, error! as NSError)
                return
            }
            
            // parse the data
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
            } catch {
                completionHandlerForGetDataTask(nil, NSError(domain: "GetDataTask JSON Serialization", code: 0, userInfo: nil))
                return
            }
            completionHandlerForGetDataTask(parsedResult as AnyObject?, nil)
        }
        task.resume()
    }
    
    
    private func escapedParameters(parameters: [String: Any]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            // Make sure value is a string
            for (key, value) in parameters {
                let stringValue = "\(value)"
                
                // Escape it
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
                
                // Append it
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
    
    func randomPageGenerator() -> String {
        let randomPage = arc4random_uniform(UInt32(FlickrConstants.FlickrParameterValues.Pages))
        return String(randomPage)
    }
    
    private func makeBBox(lat latitude: Double,  long longitude: Double) -> String {
        
        let minimumLon = max(longitude - FlickrConstants.BBox.Width, FlickrConstants.BBox.LonRange.0)
        let maximumLon = min(longitude + FlickrConstants.BBox.Width, FlickrConstants.BBox.LonRange.1)
        
        let minimumLat = max(latitude - FlickrConstants.BBox.Height, FlickrConstants.BBox.LatRange.0)
        let maximumLat = min(latitude + FlickrConstants.BBox.Height, FlickrConstants.BBox.LatRange.1)

        return "\(minimumLon),\(minimumLat),\(maximumLon),\(maximumLat)"
    }
    
}

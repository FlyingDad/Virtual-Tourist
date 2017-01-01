//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 12/5/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation


class FlickrClient {
    
    
    func getLocationId(lat: Double, lon: Double, completionHandlerForGetLocationId: @escaping (_ data: AnyObject?, _ error: NSError?) -> Void) {
        
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
            //print(placeId)
            completionHandlerForGetLocationId(placeId as AnyObject, nil)
        }
    }
    
    func getPhotoDataForLocationId(locationId: String, completionHandlerForGetPhotoDataForLocationId: @escaping(_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        let methodParameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.photoSearchMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.PlaceId: locationId,
            FlickrConstants.FlickrParameterKeys.PerPage: FlickrConstants.FlickrParameterValues.PerPage,
            FlickrConstants.FlickrParameterKeys.Pages: FlickrConstants.FlickrParameterValues.Pages,
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
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
            
            /* GUARD: Is there a place in the result? */
            guard let photos = data?[FlickrConstants.FlickrResponseKeys.Photos] as? [String:AnyObject] else {
                completionHandlerForGetPhotoDataForLocationId(nil, NSError(domain: "Get Photo Data - no photos found", code: 300, userInfo: nil))
                    return
            }
            
            //print("--->>> Photos: \(photos)")
            completionHandlerForGetPhotoDataForLocationId(photos as AnyObject, nil)
        }
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
}

//
//  FlickrClient.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 12/5/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

import Foundation


class FlickrClient {
    
    
    func getLocationId(lat: Double, lon: Double, completionHandler: @escaping (_ success: Bool, _ data: String, _ error: String) -> Void) {
        
        var success = false
        
        let methodParameters = [
            FlickrConstants.FlickrParameterKeys.Method: FlickrConstants.FlickrParameterValues.LatLonMethod,
            FlickrConstants.FlickrParameterKeys.APIKey: FlickrConstants.FlickrParameterValues.APIKey,
            FlickrConstants.FlickrParameterKeys.Latitude: String(lat),
            FlickrConstants.FlickrParameterKeys.Longitude: String(lon),
            FlickrConstants.FlickrParameterKeys.Format: FlickrConstants.FlickrParameterValues.ResponseFormat,
            FlickrConstants.FlickrParameterKeys.NoJSONCallback: FlickrConstants.FlickrParameterValues.DisableJSONCallback
        ]

        let urlString = FlickrConstants.Flickr.APIBaseUrl + escapedParameters(parameters: methodParameters)
        let url = URL(string: urlString)!
        let session = URLSession.shared
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request) { (data, response, error) in
            
            // if an error occurs, print it and re-enable the UI
            func displayError(error: String) {
                print(error)
                print("URL at time of error: \(url)")
                completionHandler(false, "", "Error getting location ID")
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                displayError(error: "There was an error with your request: \(error)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                displayError(error: "Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                displayError(error: "No data was returned by the request!")
                return
            }
            
            // parse the data
            let parsedResult: [String: AnyObject]
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as! [String:AnyObject]
            } catch {
                displayError(error: "Could not parse the data as JSON: '\(data)'")
                return
            }
            
            /* GUARD: Did Flickr return an error (stat != ok)? */
            guard let stat = parsedResult[FlickrConstants.FlickrResponseKeys.Status] as? String, stat == FlickrConstants.FlickrResponseValues.StatusOK else {
                displayError(error: "Flickr API returned an error. See error code and message in \(parsedResult)")
                return
            }
            
            //print(parsedResult)
            
            /* GUARD: Is there a place in the result? */
            guard let places = parsedResult[FlickrConstants.FlickrResponseKeys.PlacesResponse] as? [String:AnyObject],
                let place = places[FlickrConstants.FlickrResponseKeys.Place] as? [[String:AnyObject]] else {
                    displayError(error: "Cannot find place '\(FlickrConstants.FlickrResponseKeys.Place)' in \(parsedResult)")
                    return
            }
            
            // Get place Id
            guard let placeId = place[0][FlickrConstants.FlickrResponseKeys.PlaceId] as? String else {
                displayError(error: "Cannot get a \(FlickrConstants.FlickrResponseKeys.PlaceId) in \(parsedResult)")
                return
            }
            //print(placeId)
            completionHandler(true, placeId, "")

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

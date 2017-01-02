//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Michael Kroth on 12/4/16.
//  Copyright © 2016 MGK Technology Solutions, LLC. All rights reserved.
//

struct FlickrConstants {
    
    struct Flickr {
        static let APIBaseUrl = "https://api.flickr.com/services/rest/"
//        static let PhotoSourceUrlPart1 = "https://farm"  /* will insert farm id after this */
//        static let PhotoSourceUrlPart2 = ".static.flickr.com/"
//        static let PhotoSize = "url_m"
    }
    
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let Latitude = "lat"
        static let Longitude = "lon"
        static let PlaceId = "place_id"
        static let Pages = "page"
        static let PerPage = "per_page"
        static let Extras = "extras"
    }
    
    struct FlickrParameterValues {
        static let LatLonMethod = "flickr.places.findByLatLon"
        static let photoSearchMethod = "flickr.photos.search"
        static let APIKey = "87407f2f6b8dfc26750ccc05ee5de163"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let PhotoSize = "_n" /* n small, 320 on longest side */
        static let PerPage = "20"
        static let Pages = "1"
        static let ExtraMediumUrl = "url_m"
    }
    
    struct FlickrResponseKeys {
        static let PlacesResponse = "places"
        static let Place = "place"
        static let PlaceId = "place_id"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Status = "stat"
    }
    
    struct FlickrResponseValues {
        static let StatusOK = "ok"
    }
    
}


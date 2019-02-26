//  Constants.swift
//  VirtualTourist
//
//  Created by Salwa Tanko on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIBaseURL = "https://api.flickr.com/services/rest/"
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let Extras = "extras"
        static let Format = "format"
        static let lat = "lat"
        static let lon = "lon"
        static let per_page = "per_page"
        static let NoJSONCallback = "nojsoncallback"
        static let page = "page"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
    
    static let API_KEY = "76ab0ae69c408d018b1933e5bf098981"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1"
        static let GalleryPhotosMethod = "flickr.photos.search"
        static let MediumURL = "url_m"
        static let per_page = 9
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Photos = "photos"
        static let Photo = "photo"
        static let MediumURL = "url_m"
    }
}

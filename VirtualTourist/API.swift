//
//  API.swift
//  VirtualTourist
//
//  Created by Salwa Tanko on 1/12/19.
//  Copyright © 2019 Udacity. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class API {
    
    static func fetchPhotos(annotation: MKPointAnnotation, completion: @escaping (String?)-> Void){
        
        let randomPageIndex = Int(arc4random_uniform(UInt32(10)))
        let methodParameters = [
            Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.GalleryPhotosMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.API_KEY,
            Constants.FlickrParameterKeys.lat: annotation.coordinate.latitude as Double,
            Constants.FlickrParameterKeys.lon: annotation.coordinate.longitude as Double,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.MediumURL,
            Constants.FlickrParameterKeys.per_page: Constants.FlickrParameterValues.per_page,
            Constants.FlickrParameterKeys.page: randomPageIndex as AnyObject,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback
            ] as [String : Any]
        
        // create url and request
        let session = URLSession.shared
        let urlString = Constants.Flickr.APIBaseURL + self.escapedParameters(methodParameters as [String:AnyObject])
        let url = URL(string: urlString)!
        let request = URLRequest(url: url)
        
        // create network request
        let task = session.dataTask(with: request) { (data, response, error) in
            
            if error != nil {
                completion("Check Network Connection")
                return
            }
            let parsedResult: [String:AnyObject]!
            do {
                parsedResult = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as! [String:AnyObject]
                
            } catch {
                completion("Could not parse the data as JSON")
                return
            }
            
            let photosDictionary = parsedResult[Constants.FlickrResponseKeys.Photos] as? [String:AnyObject]
            
            let photos = photosDictionary![Constants.FlickrResponseKeys.Photo] as? [[String:AnyObject]]
            Photos.photos.removeAll()
            for photo in photos! {
                let pic = photo[Constants.FlickrResponseKeys.MediumURL] as? String
                Photos.photos.append(pic!)
            }
            
            completion(nil)
        }
        
        task.resume()
    }
    
    static func escapedParameters(_ parameters: [String:AnyObject]) -> String {
        
        if parameters.isEmpty {
            return ""
        } else {
            var keyValuePairs = [String]()
            
            for (key, value) in parameters {
                
                let stringValue = "\(value)"
                
                let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                
                keyValuePairs.append(key + "=" + "\(escapedValue!)")
                
            }
            return "?\(keyValuePairs.joined(separator: "&"))"
        }
    }
}

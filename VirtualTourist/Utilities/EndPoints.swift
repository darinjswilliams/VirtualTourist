//
//  EndPoints.swift
//  VirtualTourist
//
//  Created by Darin Williams on 5/15/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

enum EndPoints {
    
   
    
   
    case loginBase
    case apiKeyFlicker
    case secretFlickr
    case getAuthentication(Double, Double)
    case getPhotos(Int, Double, Double)
    case getImageUrl(Int, Int, Int, String)
 
    
    
    var stringValue: String {
        switch self {
        case .loginBase: return "https://api.flickr.com/services/rest?api_key="
       
        case .apiKeyFlicker:
            return "33911d170f574be0044d7bb44acd18c5"
            
        case .secretFlickr:
            return "658f2cacfe33be62"
            
        case .getAuthentication(let latitude, let longitude):
            return EndPoints.loginBase.stringValue + EndPoints.apiKeyFlicker.stringValue + "&method=flickr.photos.search&format=json&tags=&accuracy=11&nojsoncallback=1&lat=\(latitude)&lon=\(longitude)"
       
        case .getPhotos(let pageNo, let latitude, let longitude):
            return EndPoints.loginBase.stringValue + EndPoints.apiKeyFlicker.stringValue +
            "&method=flickr.photos.search&format=json&tags=&page=\(pageNo)&accuracy=12&nojsoncallback=1&lat=\(latitude)&lon=\(longitude)&radius=1"
        case .getImageUrl(let farm, let serverID, let id, let secret):
            return  "https://farm\(farm).staticflickr.com/\(serverID)/\(id)_\(secret).jpg"
        }
    }
    
    var url: URL {
        return URL(string: stringValue)!
    }
}


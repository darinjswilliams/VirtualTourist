//
//  FlickrVirtualTouristAPI.swift
//  VirtualTourist
//
//  Created by Darin Williams on 5/15/19.
//  Copyright © 2019 dwilliams. All rights reserved.
//

import Foundation

class ParseFickrAPI {
    
    
    class func processPhotos(url: URL, completionHandler: @escaping (FlickerResponse?, Error?)-> Void){
        
        taskForGETRequest(url: url, response: FlickerResponse.self) { (response, error) in
            guard let response = response else {
                print("requestforPhotos: Failed")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
    }
    
    
    class func getPhotoLocationByPageNumber(url: URL, completionHandler: @escaping (FlickerResponse?, Error?)-> Void){
        
       self.taskForGETRequest(url: url, response: FlickerResponse.self) { (response, error) in
            guard let response = response else {
                print("getPhotos: Failed")
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(response, error)
            }
        }
    }
    
    
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL,response: ResponseType.Type,  completionHandler: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        
        var request = URLRequest(url: url)
        
        request.httpMethod = AuthenticationUtils.headerGet
        
        print("here is the url \(request)")
        
  
        let downloadTask = URLSession.shared.dataTask(with: request) {
            (data, response, error) in
            // guard there is data
            guard let data = data else {
                // TODO: CompleteHandler can return error
                DispatchQueue.main.async {
                    completionHandler(nil, error)
                }
                return
            }
            
            
            let jsonDecoder = JSONDecoder()
            do {
                let result = try? jsonDecoder.decode(ResponseType.self, from: data)
                print("Second Print:..." + String(data: data, encoding: .utf8)!)
                
                DispatchQueue.main.async {
                    completionHandler(result, nil)
                }
                
            } catch {
                DispatchQueue.main.async {
                    completionHandler(nil,error)
                }
            }
        }
        
        downloadTask.resume()
        
        return downloadTask
    }
    
    
    
    
}

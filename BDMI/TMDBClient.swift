//
//  TMDBClient.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class TMDBClient {
    
    static let sharedInstance = TMDBClient()
    private init() {}
    
    var session = NSURLSession.sharedSession()
    
    // configuration object
    var config = TMDBConfig()
    
    // authentication state
    var requestToken: String? = nil
    var sessionID: String? = nil
    var userID: Int? = nil
    
    // MARK: GET
    
    func taskForGETMethod(method: String, var parameters: [String:AnyObject], completionHandlerForGET: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        parameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        let url = tmdbURLFromParameters(parameters, withPathExtension: method)
        
        let request = NSMutableURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForGET(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            guard let stat = (response as? NSHTTPURLResponse)?.statusCode where stat != 429 else {
                sendError("Your request count (#) is over the allowed limit of (40). Try again later.")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }

            Utilities.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForGET)
        }
        
        task.resume()
        
        return task
    }
    
    func taskForGETImage(size: String, filePath: String, completionHandlerForImage: (imageData: NSData?, error: NSError?) -> Void) -> NSURLSessionTask {
        
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForImage(imageData: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            completionHandlerForImage(imageData: data, error: nil)
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: POST
    
    func taskForPOSTMethod(method: String, var parameters: [String:AnyObject], jsonBody: String, completionHandlerForPOST: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        parameters[ParameterKeys.ApiKey] = Constants.ApiKey
        
        let request = NSMutableURLRequest(URL: tmdbURLFromParameters(parameters, withPathExtension: method))
        request.HTTPMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.HTTPBody = jsonBody.dataUsingEncoding(NSUTF8StringEncoding)
        
        let task = session.dataTaskWithRequest(request) { (data, response, error) in
            
            func sendError(error: String) {
                print(error)
                let userInfo = [NSLocalizedDescriptionKey : error]
                completionHandlerForPOST(result: nil, error: NSError(domain: "taskForGETMethod", code: 1, userInfo: userInfo))
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!.localizedDescription)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? NSHTTPURLResponse)?.statusCode where statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
    
            Utilities.convertDataWithCompletionHandler(data, completionHandlerForConvertData: completionHandlerForPOST)
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: Helpers
    
    // substitute the key for the value that is contained within the method name
    func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }
    
    func createUrlForImages(size: String, filePath: String) -> NSURL {
        let baseURL = NSURL(string: config.baseImageURLString)!
        let url = baseURL.URLByAppendingPathComponent(size).URLByAppendingPathComponent(filePath)
        return url
    }
    
    // create a URL from parameters
    private func tmdbURLFromParameters(parameters: [String:AnyObject], withPathExtension: String? = nil) -> NSURL {
        
        let components = NSURLComponents()
        components.scheme = TMDBClient.Constants.ApiScheme
        components.host = TMDBClient.Constants.ApiHost
        components.path = TMDBClient.Constants.ApiPath + (withPathExtension ?? "")
        components.queryItems = [NSURLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = NSURLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.URL!
    }
}

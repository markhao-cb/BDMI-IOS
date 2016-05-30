//
//  TMDBConvenience.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import Foundation

// MARK: - TMDBClient (Convenient Resource Methods)

extension TMDBClient {
    
    func authenticateWithViewController(hostViewController: UIViewController, completionHandlerForAuth: (success: Bool, errorString: String?) -> Void) {
        
        getRequestToken() { (success, requestToken, errorString) in
            
            if success {
                
                self.requestToken = requestToken
                
                self.loginWithToken(requestToken, hostViewController: hostViewController) { (success, errorString) in
                    
                    if success {
                        self.getSessionID(requestToken) { (success, sessionID, errorString) in
                            
                            if success {
                                
                                self.sessionID = sessionID
                                
                                self.getUserID() { (success, userID, errorString) in
                                    
                                    if success {
                                        
                                        if let userID = userID {
                                            
                                            self.userID = userID
                                        }
                                    }
                                    
                                    completionHandlerForAuth(success: success, errorString: errorString)
                                }
                            } else {
                                completionHandlerForAuth(success: success, errorString: errorString)
                            }
                        }
                    } else {
                        completionHandlerForAuth(success: success, errorString: errorString)
                    }
                }
            } else {
                completionHandlerForAuth(success: success, errorString: errorString)
            }
        }
    }
    
    private func getRequestToken(completionHandlerForToken: (success: Bool, requestToken: String?, errorString: String?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        taskForGETMethod(Methods.AuthenticationTokenNew, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForToken(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
            } else {
                if let requestToken = results[TMDBClient.JSONResponseKeys.RequestToken] as? String {
                    completionHandlerForToken(success: true, requestToken: requestToken, errorString: nil)
                } else {
                    print("Could not find \(TMDBClient.JSONResponseKeys.RequestToken) in \(results)")
                    completionHandlerForToken(success: false, requestToken: nil, errorString: "Login Failed (Request Token).")
                }
            }
        }
    }
    
    private func loginWithToken(requestToken: String?, hostViewController: UIViewController, completionHandlerForLogin: (success: Bool, errorString: String?) -> Void) {
        
        let authorizationURL = NSURL(string: "\(TMDBClient.Constants.AuthorizationURL)\(requestToken!)")
        let request = NSURLRequest(URL: authorizationURL!)
        let webAuthViewController = hostViewController.storyboard!.instantiateViewControllerWithIdentifier("TMDBAuthViewController") as! TMDBAuthViewController
        webAuthViewController.urlRequest = request
        webAuthViewController.requestToken = requestToken
        webAuthViewController.completionHandlerForView = completionHandlerForLogin
        
        let webAuthNavigationController = UINavigationController()
        webAuthNavigationController.pushViewController(webAuthViewController, animated: false)
        
        performUIUpdatesOnMain {
            hostViewController.presentViewController(webAuthNavigationController, animated: true, completion: nil)
        }
    }
    
    private func getSessionID(requestToken: String?, completionHandlerForSession: (success: Bool, sessionID: String?, errorString: String?) -> Void) {
        
        let parameters = [TMDBClient.ParameterKeys.RequestToken: requestToken!]
        
        taskForGETMethod(Methods.AuthenticationSessionNew, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
            } else {
                if let sessionID = results[TMDBClient.JSONResponseKeys.SessionID] as? String {
                    completionHandlerForSession(success: true, sessionID: sessionID, errorString: nil)
                } else {
                    print("Could not find \(TMDBClient.JSONResponseKeys.SessionID) in \(results)")
                    completionHandlerForSession(success: false, sessionID: nil, errorString: "Login Failed (Session ID).")
                }
            }
        }
    }
    
    private func getUserID(completionHandlerForUserID: (success: Bool, userID: Int?, errorString: String?) -> Void) {
        
        let parameters = [TMDBClient.ParameterKeys.SessionID: TMDBClient.sharedInstance.sessionID!]
        
        taskForGETMethod(Methods.Account, parameters: parameters) { (results, error) in
            
            if let error = error {
                print(error)
                completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
            } else {
                if let userID = results[TMDBClient.JSONResponseKeys.UserID] as? Int {
                    completionHandlerForUserID(success: true, userID: userID, errorString: nil)
                } else {
                    print("Could not find \(TMDBClient.JSONResponseKeys.UserID) in \(results)")
                    completionHandlerForUserID(success: false, userID: nil, errorString: "Login Failed (User ID).")
                }
            }
        }
    }
    
    // MARK: GET Convenience Methods
    
    func getNowPlayingMovies(completionHandlerForNowPlayingMovies: (result: [TMDBMovie]?, error: NSError?) -> Void) {
        
        let parameters = [String: AnyObject]()
        let method = TMDBClient.Methods.NowPlaying
        
        taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForNowPlayingMovies(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForNowPlayingMovies(result: movies, error: nil)
                } else {
                    completionHandlerForNowPlayingMovies(result: nil, error: NSError(domain: "getNowPlayingMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getNowPlayingMovies"]))
                }
            }
        }
    }
    
    func getMoviesBy(method: String, completionHandlerFoGetMovies: (result: [TMDBMovie]?, error: NSError?) -> Void) {
        
        let parameters = [String: AnyObject]()
        let method = method
        
        taskForGETMethod(method, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandlerFoGetMovies(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerFoGetMovies(result: movies, error: nil)
                } else {
                    completionHandlerFoGetMovies(result: nil, error: NSError(domain: "getMovies \(method) parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMovies (\(method))"]))
                }
            }
        }
    }
    
    func getMovieDetailBy(id: Int, completionHandlerForWatchlist: (result: TMDBMovie?, error: NSError?) -> Void) {
        
        let parameters = [String: AnyObject]()
        var mutableMethod: String = Methods.MovieDetail
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: TMDBClient.URLKeys.MovieID, value: String(id))!
        
        taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForWatchlist(result: nil, error: error)
            } else {
                
                if let results = results as? [String:AnyObject] {
                    
                    let movie = TMDBMovie(dictionary: results)
                    completionHandlerForWatchlist(result: movie, error: nil)
                } else {
                    completionHandlerForWatchlist(result: nil, error: NSError(domain: "getWatchlistMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getWatchlistMovies"]))
                }
            }
        }
    }
    
    
    func getWatchlistMovies(completionHandlerForWatchlist: (result: [TMDBMovie]?, error: NSError?) -> Void) {
        
        let parameters = [TMDBClient.ParameterKeys.SessionID: TMDBClient.sharedInstance.sessionID!]
        var mutableMethod: String = Methods.AccountIDWatchlistMovies
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance.userID!))!
        
        taskForGETMethod(mutableMethod, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForWatchlist(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForWatchlist(result: movies, error: nil)
                } else {
                    completionHandlerForWatchlist(result: nil, error: NSError(domain: "getWatchlistMovies parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getWatchlistMovies"]))
                }
            }
        }
    }
    
    func getMoviesForSearchString(searchString: String, completionHandlerForMovies: (result: [TMDBMovie]?, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
        let parameters = [TMDBClient.ParameterKeys.Query: searchString]
        
        let task = taskForGETMethod(Methods.SearchMovie, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForMovies(result: nil, error: error)
            } else {
                
                if let results = results[TMDBClient.JSONResponseKeys.MovieResults] as? [[String:AnyObject]] {
                    
                    let movies = TMDBMovie.moviesFromResults(results)
                    completionHandlerForMovies(result: movies, error: nil)
                } else {
                    completionHandlerForMovies(result: nil, error: NSError(domain: "getMoviesForSearchString parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getMoviesForSearchString"]))
                }
            }
        }
        
        return task
    }
    
    func getConfig(completionHandlerForConfig: (didSucceed: Bool, error: NSError?) -> Void) {
        
        let parameters = [String:AnyObject]()
        
        taskForGETMethod(Methods.Config, parameters: parameters) { (results, error) in
            
            if let error = error {
                completionHandlerForConfig(didSucceed: false, error: error)
            } else if let newConfig = TMDBConfig(dictionary: results as! [String:AnyObject]) {
                self.config = newConfig
                completionHandlerForConfig(didSucceed: true, error: nil)
            } else {
                completionHandlerForConfig(didSucceed: false, error: NSError(domain: "getConfig parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse getConfig"]))
            }
        }
    }
    
    // MARK: POST Convenience Methods
    
    func postToFavorites(movie: TMDBMovie, favorite: Bool, completionHandlerForFavorite: (result: Int?, error: NSError?) -> Void)  {
        
        let parameters = [TMDBClient.ParameterKeys.SessionID : TMDBClient.sharedInstance.sessionID!]
        var mutableMethod: String = Methods.AccountIDFavorite
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance.userID!))!
        let jsonBody = "{\"\(TMDBClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(TMDBClient.JSONBodyKeys.MediaID)\": \"\(movie.id)\",\"\(TMDBClient.JSONBodyKeys.Favorite)\": \(favorite)}"
        
        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                completionHandlerForFavorite(result: nil, error: error)
            } else {
                if let results = results[TMDBClient.JSONResponseKeys.StatusCode] as? Int {
                    completionHandlerForFavorite(result: results, error: nil)
                } else {
                    completionHandlerForFavorite(result: nil, error: NSError(domain: "postToFavoritesList parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToFavoritesList"]))
                }
            }
        }
    }
    
    func postToWatchlist(movie: TMDBMovie, watchlist: Bool, completionHandlerForWatchlist: (result: Int?, error: NSError?) -> Void) {
        
        let parameters = [TMDBClient.ParameterKeys.SessionID : TMDBClient.sharedInstance.sessionID!]
        var mutableMethod: String = Methods.AccountIDWatchlist
        mutableMethod = subtituteKeyInMethod(mutableMethod, key: TMDBClient.URLKeys.UserID, value: String(TMDBClient.sharedInstance.userID!))!
        let jsonBody = "{\"\(TMDBClient.JSONBodyKeys.MediaType)\": \"movie\",\"\(TMDBClient.JSONBodyKeys.MediaID)\": \"\(movie.id)\",\"\(TMDBClient.JSONBodyKeys.Watchlist)\": \(watchlist)}"
        
        taskForPOSTMethod(mutableMethod, parameters: parameters, jsonBody: jsonBody) { (results, error) in
            
            if let error = error {
                completionHandlerForWatchlist(result: nil, error: error)
            } else {
                if let results = results[TMDBClient.JSONResponseKeys.StatusCode] as? Int {
                    completionHandlerForWatchlist(result: results, error: nil)
                } else {
                    completionHandlerForWatchlist(result: nil, error: NSError(domain: "postToWatchlist parsing", code: 0, userInfo: [NSLocalizedDescriptionKey: "Could not parse postToWatchlist"]))
                }
            }
        }
    }
}

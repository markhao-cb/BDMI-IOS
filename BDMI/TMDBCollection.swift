//
//  TMDBCollection.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

struct TMDBCollection {
    
    var backdropPath : String?
    var id : Int!
    var name : String!
    var posterPath : String?
    var overview: String?
    var parts : [[String: AnyObject]]?
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        backdropPath = dictionary[TMDBClient.JSONResponseKeys.CollectionBackdropPath] as? String
        id = dictionary[TMDBClient.JSONResponseKeys.CollectionID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.CollectionPoster] as? String
        name = dictionary[TMDBClient.JSONResponseKeys.CollectionName] as? String
        overview = dictionary[TMDBClient.JSONResponseKeys.CollectionOverview] as? String
        posterPath = dictionary[TMDBClient.JSONResponseKeys.CollectionPosterPath] as? String
        parts = dictionary[TMDBClient.JSONResponseKeys.CollectionParts] as? [[String: AnyObject]]
    }
    
    static func collectionsFromResults(results: [[String:AnyObject]]) -> [TMDBCollection] {
        
        var collections = [TMDBCollection]()
        
        for result in results {
            collections.append(TMDBCollection(dictionary: result))
        }
        
        return collections
    }
}

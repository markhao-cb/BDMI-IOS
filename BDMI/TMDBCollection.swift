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
    var parts : [TMDBMovie]!
    var posterPath : String?
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        backdropPath = dictionary[TMDBClient.JSONResponseKeys.CollectionBackdrop] as? String
        id = dictionary[TMDBClient.JSONResponseKeys.CollectionID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.CollectionPoster] as? String
        name = dictionary[TMDBClient.JSONResponseKeys.CollectionName] as? String
        parts = TMDBMovie.moviesFromResults(dictionary[TMDBClient.JSONResponseKeys.CollectionParts] as! [[String: AnyObject]])
    }
    
    static func collectionsFromResults(results: [[String:AnyObject]]) -> [TMDBCollection] {
        
        var collections = [TMDBCollection]()
        
        for result in results {
            collections.append(TMDBCollection(dictionary: result))
        }
        
        return collections
    }
}

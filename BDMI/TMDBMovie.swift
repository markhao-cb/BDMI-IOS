//
//  TMDBMovie.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//


struct TMDBMovie {
    
    // MARK: Properties
    
    var title: String
    var id: Int
    var posterPath: String?
    var releaseYear: String?
    var voteAverage : Float?
    var overview : String?
    var voteCount : Int?
    var popularity : Float?
    var runtime: Int?
    var backdropPath: String?
    var belongsToCollection : [String: AnyObject]?
    
    
    // MARK: Initializers
    
    // construct a TMDBMovie from a dictionary
    init(dictionary: [String:AnyObject]) {
        title = dictionary[TMDBClient.JSONResponseKeys.MovieTitle] as! String
        id = dictionary[TMDBClient.JSONResponseKeys.MovieID] as! Int
        posterPath = dictionary[TMDBClient.JSONResponseKeys.MoviePosterPath] as? String
        overview = dictionary[TMDBClient.JSONResponseKeys.MovieOverView] as? String
        voteCount = dictionary[TMDBClient.JSONResponseKeys.MovieVoteCount] as? Int
        voteAverage = dictionary[TMDBClient.JSONResponseKeys.MovieVoteAverage] as? Float
        popularity = dictionary[TMDBClient.JSONResponseKeys.MoviePopularity] as? Float
        runtime = dictionary[TMDBClient.JSONResponseKeys.MovieRuntime] as? Int
        backdropPath = dictionary[TMDBClient.JSONResponseKeys.MovieBackdropPath] as? String
        belongsToCollection = dictionary[TMDBClient.JSONResponseKeys.MovieCollection] as? [String: AnyObject]
        
        if let releaseDateString = dictionary[TMDBClient.JSONResponseKeys.MovieReleaseDate] as? String where releaseDateString.isEmpty == false {
            releaseYear = releaseDateString.substringToIndex(releaseDateString.startIndex.advancedBy(4))
        } else {
            releaseYear = ""
        }
    }
    
    static func moviesFromResults(results: [[String:AnyObject]]) -> [TMDBMovie] {
        
        var movies = [TMDBMovie]()
        
        for result in results {
            movies.append(TMDBMovie(dictionary: result))
        }
        
        return movies
    }
}

// MARK: - TMDBMovie: Equatable

extension TMDBMovie: Equatable {}

func ==(lhs: TMDBMovie, rhs: TMDBMovie) -> Bool {
    return lhs.id == rhs.id
}

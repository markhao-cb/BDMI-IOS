//
//  TMDBConstants.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//


extension TMDBClient {
    
    // MARK: Constants
    struct Constants {
        
        // MARK: API Key
        static let ApiKey : String = "fbf232e8d3d25407ff1c8ca12f0f5cb7"
        
        // MARK: URLs
        static let ApiScheme = "https"
        static let ApiHost = "api.themoviedb.org"
        static let ApiPath = "/3"
        static let AuthorizationURL : String = "https://www.themoviedb.org/authenticate/"
    }
    
    // MARK: Methods
    struct Methods {
        
        // MARK: Account
        static let Account = "/account"
        static let AccountIDFavoriteMovies = "/account/{id}/favorite/movies"
        static let AccountIDFavorite = "/account/{id}/favorite"
        static let AccountIDWatchlistMovies = "/account/{id}/watchlist/movies"
        static let AccountIDWatchlist = "/account/{id}/watchlist"
        
        // MARK: Authentication
        static let AuthenticationTokenNew = "/authentication/token/new"
        static let AuthenticationSessionNew = "/authentication/session/new"
        
        // MARK: Search
        static let SearchMovie = "/search/movie"
        
        // MARK: Config
        static let Config = "/configuration"
        
        // MARK: General
        static let NowPlaying = "/movie/now_playing"
        static let UpComing = "/movie/upcoming"
        static let TopRated = "/movie/top_rated"
        static let Popular = "/movie/popular"
        static let Latest = "/movie/latest"
        static let MovieDetail = "/movie/{id}"
    }
    
    // MARK: URL Keys
    struct URLKeys {
        static let UserID = "id"
        static let MovieID = "id"

    }
    
    // MARK: Parameter Keys
    struct ParameterKeys {
        static let ApiKey = "api_key"
        static let SessionID = "session_id"
        static let RequestToken = "request_token"
        static let Query = "query"
    }
    
    // MARK: JSON Body Keys
    struct JSONBodyKeys {
        static let MediaType = "media_type"
        static let MediaID = "media_id"
        static let Favorite = "favorite"
        static let Watchlist = "watchlist"
    }
    
    // MARK: JSON Response Keys
    struct JSONResponseKeys {
        
        // MARK: General
        static let StatusMessage = "status_message"
        static let StatusCode = "status_code"
        
        // MARK: Authorization
        static let RequestToken = "request_token"
        static let SessionID = "session_id"
        
        // MARK: Account
        static let UserID = "id"
        
        // MARK: Config
        static let ConfigBaseImageURL = "base_url"
        static let ConfigSecureBaseImageURL = "secure_base_url"
        static let ConfigImages = "images"
        static let ConfigPosterSizes = "poster_sizes"
        static let ConfigProfileSizes = "profile_sizes"
        
        // MARK: Movies
        static let MovieID = "id"
        static let MovieTitle = "title"
        static let MoviePosterPath = "poster_path"
        static let MovieReleaseDate = "release_date"
        static let MovieReleaseYear = "release_year"
        static let MovieResults = "results"
        static let MovieOverView = "overview"
        static let MovieVoteAverage = "vote_average"
        static let MovieVoteCount = "vote_count"
        static let MoviePopularity = "popularity"
    }
    
    // MARK: Poster Sizes
    struct PosterSizes {
        static let RowPoster = TMDBClient.sharedInstance.config.posterSizes[2]
        static let DetailPoster = TMDBClient.sharedInstance.config.posterSizes[4]
    }
}

//
//  CoreDataConvenience.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/31/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import Foundation
import CoreData

extension CoreDataStack {
    
    //CoreData
     func objectSavedInCoreData(id: Int, entity: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest(entityName: entity)
        let predicate = NSPredicate(format: "id = %d", id)
        fetchRequest.predicate = predicate
        do {
            let result = try context.executeFetchRequest(fetchRequest)
            return result.first
        } catch {
            return nil
        }
    }
    
     func createNewMovie(movie: TMDBMovie) -> Movie {
        
        let id = movie.id
        let title = movie.title
        var posterUrl: NSURL? = nil
        var posterPath : String?
        if let path = movie.posterPath {
            posterUrl = TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.RowPoster, filePath: path)
            posterPath = path
        }
        let backdropPath = movie.backdropPath
        let overview = movie.overview
        let voteAverage = movie.voteAverage
        let voteCount = movie.voteCount
        let runtime = movie.runtime
        let popularity = movie.popularity
        let releaseDate = movie.releaseYear
        
        let newMovie = Movie(id: id, title: title, posterUrl: posterUrl, posterPath: posterPath , backdropPath: backdropPath, overview: overview, voteAverage: voteAverage, voteCount: voteCount, runtime: runtime, releaseDate: releaseDate, popularity: popularity, context: context)
        print("New Movie Created!")
        
        return newMovie
    }
    
     func createNewCollection(collection: TMDBCollection) -> Collection {
        let name = collection.name
        let id = collection.id
        let overview = collection.overview
        let posterPath = collection.posterPath
        var backdropUrl: NSURL? = nil
        var backdropPath: String?
        
        if let path = collection.backdropPath {
            backdropUrl = TMDBClient.sharedInstance.createUrlForImages(TMDBClient.BackdropSizes.DetailBackdrop, filePath: path)
            backdropPath = path
        }
        let newCollection = Collection(name: name, id: id, overview: overview, backdrop: backdropUrl, backdropPath: backdropPath, posterPath: posterPath, context: context)
        
        print("New Collection Created!")
        do {
            try context.save()
        } catch {
            let error = error as NSError
            print("Error while saving. Error: \(error.localizedDescription)")
        }
        return newCollection
    }
    
}
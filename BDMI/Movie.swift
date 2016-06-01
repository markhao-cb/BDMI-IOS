//
//  Movie.swift
//  
//
//  Created by Yu Qi Hao on 5/29/16.
//
//

import Foundation
import CoreData


class Movie: NSManagedObject {
    
    convenience init(id: Int, title: String, posterUrl: NSURL?, posterPath: String?, backdropPath: String?, overview: String?, voteAverage: Float?, voteCount: Int?, runtime: Int?, releaseDate: String?, popularity: Float?, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entityForName(CoreDataEntityNames.Movie, inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.id = id
            self.title = title
            if let path = posterUrl {
                self.poster = NSData(contentsOfURL: path)
            }
            self.posterPath = posterPath
            self.backdropPath = backdropPath
            self.overview = overview
            self.voteAverage = voteAverage
            self.voteCount = voteCount
            self.runtime = runtime
            self.popularity = popularity
            self.releaseDate = releaseDate
        } else {
            fatalError("Could not find entity named: \(CoreDataEntityNames.Movie)")
        }
    }

}

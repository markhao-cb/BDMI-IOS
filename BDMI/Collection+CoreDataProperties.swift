//
//  Collection+CoreDataProperties.swift
//  
//
//  Created by Yu Qi Hao on 5/29/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Collection {

    @NSManaged var backdrop: NSData?
    @NSManaged var name: String?
    @NSManaged var id: NSNumber?
    @NSManaged var movies: NSSet?
    
    @NSManaged func addMoviesObject(movie: Movie)
    @NSManaged func removeMoviesObject(movie: Movie)
    @NSManaged func addMovies(movies: NSSet)
    @NSManaged func removeMovies(movies: NSSet)

}

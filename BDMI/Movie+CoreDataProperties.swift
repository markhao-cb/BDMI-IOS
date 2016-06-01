//
//  Movie+CoreDataProperties.swift
//  
//
//  Created by Yu Qi Hao on 5/31/16.
//
//
//  Choose "Create NSManagedObject Subclass…" from the Core Data editor menu
//  to delete and recreate this implementation file for your updated model.
//

import Foundation
import CoreData

extension Movie {

    @NSManaged var id: NSNumber?
    @NSManaged var overview: String?
    @NSManaged var popularity: NSNumber?
    @NSManaged var poster: NSData?
    @NSManaged var releaseDate: String?
    @NSManaged var runtime: NSNumber?
    @NSManaged var title: String?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var voteCount: NSNumber?
    @NSManaged var posterPath: String?
    @NSManaged var backdropPath: String?
    @NSManaged var collections: NSSet?
    
    @NSManaged func addCollectionsObject(collection: Collection)
    @NSManaged func removeCollectionsObject(collection: Collection)
    @NSManaged func addCollections(collections: NSSet)
    @NSManaged func removeCollections(collections: NSSet)

}

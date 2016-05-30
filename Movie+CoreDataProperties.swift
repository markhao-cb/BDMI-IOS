//
//  Movie+CoreDataProperties.swift
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

extension Movie {

    @NSManaged var title: String?
    @NSManaged var id: NSNumber?
    @NSManaged var poster: NSData?
    @NSManaged var overview: String?
    @NSManaged var releaseDate: String?
    @NSManaged var voteAverage: NSNumber?
    @NSManaged var voteCount: NSNumber?
    @NSManaged var popularity: NSNumber?
    @NSManaged var runtime: NSNumber?
    @NSManaged var collections: NSSet?

}

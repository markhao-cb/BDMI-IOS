//
//  FavoriteMovie+CoreDataProperties.swift
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

extension FavoriteMovie {

    @NSManaged var title: String?
    @NSManaged var movieID: NSNumber?
    @NSManaged var poster: NSData?
    @NSManaged var favoriteDate: NSDate?

}

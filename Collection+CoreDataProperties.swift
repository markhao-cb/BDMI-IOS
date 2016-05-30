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

}

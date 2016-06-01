//
//  Collection.swift
//  
//
//  Created by Yu Qi Hao on 5/29/16.
//
//

import Foundation
import CoreData


class Collection: NSManagedObject {

    convenience init(name: String, id: Int, overview: String?, backdrop: NSURL?, backdropPath: String?, posterPath: String?, context: NSManagedObjectContext) {
        
        if let entity = NSEntityDescription.entityForName(CoreDataEntityNames.Collection, inManagedObjectContext: context) {
            self.init(entity: entity, insertIntoManagedObjectContext: context)
            self.id = id
            self.name = name
            if let path = backdrop {
                self.rowBackdrop = NSData(contentsOfURL: path)
            }
            self.detailBackDropPath = backdropPath
            self.detailPosterPath = posterPath
            self.overview = overview
            self.creationDate = NSDate()
            
        } else {
            fatalError("Could not find entity named: \(CoreDataEntityNames.Movie)")
        }
    }
}

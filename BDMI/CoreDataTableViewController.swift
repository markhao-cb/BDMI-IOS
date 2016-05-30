//
//  CoreDataTableViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import CoreData

class CoreDataTableViewController: UITableViewController {
    
    // MARK:  - Properties
    var fetchedResultsController : NSFetchedResultsController? {
        didSet {
            // Whenever the frc changes, we execute the search and
            // reload the table
            executeSearch()
            tableView.reloadData()
        }
    }
    
    init(fetchedResultsController fc : NSFetchedResultsController,
                                  style : UITableViewStyle = .Plain){
        fetchedResultsController = fc
        super.init(style: style)
    }
    
    // Do not worry about this initializer. It has to be implemented
    // because of the way Swift interfaces with an Objective C
    // protocol called NSArchiving. It's not relevant.
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
}

// MARK:  - View Lifecycle
extension CoreDataTableViewController{
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        // Add a default title if you forgot it
        if title == nil{
            title = fetchedResultsController!.fetchRequest.entity?.name
        }
        
    }
}

// MARK:  - Subclass responsability
extension CoreDataTableViewController{
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        fatalError("This method MUST be implemented by a subclass of CoreDataTableViewController")
    }
}

// MARK:  - Table Data Source
extension CoreDataTableViewController{
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return (fetchedResultsController!.sections?.count)!;
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController!.sections![section].numberOfObjects;
    }
    
    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultsController!.sections![section].name;
    }
    
    override func tableView(tableView: UITableView, sectionForSectionIndexTitle title: String, atIndex index: Int) -> Int {
        return fetchedResultsController!.sectionForSectionIndexTitle(title, atIndex: index)
    }
    
    override func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        return  fetchedResultsController!.sectionIndexTitles
    }
    
}

// MARK:  - Fetches
extension CoreDataTableViewController{
    
    func executeSearch(){
        do{
            try fetchedResultsController!.performFetch()
        }catch let e as NSError{
            print("Error while trying to perform a search: \n\(e)\n\(fetchedResultsController)")
        }
    }
}


// MARK:  - Delegate
extension CoreDataTableViewController: NSFetchedResultsControllerDelegate{
    
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController,
                    didChangeSection sectionInfo: NSFetchedResultsSectionInfo,
                                     atIndex sectionIndex: Int,
                                             forChangeType type: NSFetchedResultsChangeType) {
        
        let set = NSIndexSet(index: sectionIndex)
        
        switch (type){
            
        case .Insert:
            tableView.insertSections(set, withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteSections(set, withRowAnimation: .Fade)
            
        default:
            // irrelevant in our case
            break
            
        }
    }
    
    
    func controller(controller: NSFetchedResultsController,
                    didChangeObject anObject: AnyObject,
                                    atIndexPath indexPath: NSIndexPath?,
                                                forChangeType type: NSFetchedResultsChangeType,
                                                              newIndexPath: NSIndexPath?) {
        
        guard let newIndexPath = newIndexPath else{
            fatalError("No indexPath received")
        }
        switch(type){
            
        case .Insert:
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            
        case .Delete:
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            
        case .Update:
            tableView.reloadRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            
        case .Move:
            tableView.deleteRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath], withRowAnimation: .Fade)
        }
        
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
}

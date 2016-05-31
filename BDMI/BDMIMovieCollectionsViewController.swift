//
//  BDMIMovieCollectionsViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import CoreData
import NVActivityIndicatorView

class BDMIMovieCollectionsViewController: UIViewController {

    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var collections : [Collection]?
    let cellSpacingHeight : CGFloat = 5
    
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchCollection()
    }
}

//MARK: Networking Methods
extension BDMIMovieCollectionsViewController {
    private func getMoviesFromCollection(collection: [Collection]) {
        
    }
}

//MARK: Core Data Methods
extension BDMIMovieCollectionsViewController {
    private func fetchCollection() {
        let fetchRequest = NSFetchRequest(entityName: CoreDataEntityNames.Collection)
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let predicate = NSPredicate(format: "backdrop != nil")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        
        NVActivityIndicatorView.showHUDAddedTo(view)
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            performUIUpdatesOnMain({
                NVActivityIndicatorView.hideHUDForView(self.view)
                self.collections = result.finalResult as? [Collection]
                self.tableView.reloadData()
            })
           
        }
        
        Utilities.appDelegate.stack.context.performBlock { 
            do {
                try Utilities.appDelegate.stack.context.executeRequest(asynchronousFetchRequest)
            } catch {
                let error = error as NSError
                print("Failed to fetch collections. Error: \(error.localizedDescription)")
                performUIUpdatesOnMain({ 
                    NVActivityIndicatorView.hideHUDForView(self.view)
                })
            }
        }
    }
}


//MARK: UITableView Delegate && DataSource
extension BDMIMovieCollectionsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let collections = collections {
            return collections.count
        } else {
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BDMIMovieCollectionsTableViewCell") as! BDMIMovieCollectionsTableViewCell
        cell.configCell()
        if let collections = collections {
            let collection = collections[indexPath.row]
            cell.backdropIV.image = UIImage(data: collection.backdrop!)
            cell.titleLabel.text = collection.name
        }
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let visibleCells = tableView.visibleCells
        
        for case let cell as BDMIMovieCollectionsTableViewCell in visibleCells {
            cell.cellOnTableViewDidScrollOnView(tableView, view: view)
        }
    }
}

//MARK: UI Related Methods 
extension BDMIMovieCollectionsViewController {
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        fetchCollection()
        refreshControl.endRefreshing()
    }
}






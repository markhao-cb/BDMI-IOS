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
import TransitionTreasury
import TransitionAnimation

class BDMIMovieCollectionsViewController: UIViewController {

    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var collections : [Collection]?
    let cellSpacingHeight : CGFloat = 5
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        addRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        fetchCollection()
    }
}

//MARK: Networking Methods
extension BDMIMovieCollectionsViewController {
    private func getMoviesForCollection(collections: [Collection]) {
        for collection in collections {
            TMDBClient.sharedInstance.getCollectionlBy(Int(collection.id!), completionHandlerForGetCollection: { (result, error) in
                guard error == nil else {
                    print("Get movie for collection failed. Error: \(error?.localizedDescription)")
                    return
                }
                
                
            })
        }
    }
}

//MARK: Core Data Methods
extension BDMIMovieCollectionsViewController {
    private func fetchCollection() {
        let fetchRequest = NSFetchRequest(entityName: CoreDataEntityNames.Collection)
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let predicate = NSPredicate(format: "rowBackdrop != nil")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        
        NVActivityIndicatorView.showHUDAddedTo(view)
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            performUIUpdatesOnMain({
                NVActivityIndicatorView.hideHUDForView(self.view)
                let collections = result.finalResult as? [Collection]
                self.collections = Array(Set(collections!))
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
extension BDMIMovieCollectionsViewController : UITableViewDataSource, UITableViewDelegate, ModalTransitionDelegate {
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
            cell.backdropIV.image = UIImage(data: collection.rowBackdrop!)
            cell.titleLabel.text = collection.name
        }
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let collection = collections![indexPath.row]
        let colletionMoviesVC = self.storyboard?.instantiateViewControllerWithIdentifier("CollectionMoviesViewController") as! CollectionMoviesViewController
        colletionMoviesVC.collection = collection
        colletionMoviesVC.modalDelegate = self
        tr_presentViewController(colletionMoviesVC, method: TRPresentTransitionMethod.Fade)
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
        refreshControl.tintColor = UIColor.whiteColor()
        refreshControl.backgroundColor = UIColor.clearColor()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        fetchCollection()
        refreshControl.endRefreshing()
    }
}






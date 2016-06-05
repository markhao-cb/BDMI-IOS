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

class BDMIMovieCollectionsViewController: BDMIViewController {

    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var collections : [Collection]?
    let cellSpacingHeight : CGFloat = 5
    var stack = Utilities.appDelegate.stack
    
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        createPlaceHolderLabel("Fetching...Come again later")
        fetchCollection()
        addRefreshControl()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        fetchCollection()
        if let collections = collections where collections.count != 0 {
            tableView.hidden = false
        } else {
            tableView.hidden = true
        }
    }
}

//MARK: Networking Methods
extension BDMIMovieCollectionsViewController {
    private func getMoviesForCollection(collections: [Collection]) {
        for collection in collections {
            Utilities.appDelegate.setNewworkActivityIndicatorVisible(true)
            TMDBClient.sharedInstance.getCollectionlBy(Int(collection.id!), completionHandlerForGetCollection: { (result, error) in
                performUIUpdatesOnMain({
                    Utilities.appDelegate.setNewworkActivityIndicatorVisible(false)
                    guard (error == nil) else {
                        print("Error while getting collection. Error: \(error?.localizedDescription)")
                        showAlertViewWith("Oops", error: (error?.localizedDescription)!, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                        return
                    }
                    //Get the collection's movie data, loop back to perfetch.
                    if let parts = result!.parts {
                        let collectionMovies = TMDBMovie.moviesFromResults(parts)
                        self.perfetchMovies(collectionMovies, forCollection: collection)
                    }
                })
            })
        }
    }
    
    private func perfetchMovies(movies: [TMDBMovie],  forCollection collection: Collection) {
        for movie in movies {
            //Check if the movie is already saved.
            if let _ = stack.objectSavedInCoreData(movie.id, entity: CoreDataEntityNames.Movie) as? Movie {} else {
                
                //Movie's not saved. Get movie details from API
                Utilities.appDelegate.setNewworkActivityIndicatorVisible(true)
                TMDBClient.sharedInstance.getMovieDetailBy(movie.id, completionHandlerForGetDetail: { (movieResult, error) in
                    performUIUpdatesOnMain({
                        Utilities.appDelegate.setNewworkActivityIndicatorVisible(false)
                        if let error = error {
                            print("Prefetch Failed. \(error.localizedDescription)")
                            showAlertViewWith("Oops", error: error.localizedDescription, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                        } else {
                            //Create new movie and save to coredata
                            let newMovie = self.stack.createNewMovie(movieResult!)
                            collection.addMoviesObject(newMovie)
                        }
                    })
                })
            }
        }
    }
}

//MARK: Core Data Methods
extension BDMIMovieCollectionsViewController {
     func fetchCollection() {
        let fetchRequest = NSFetchRequest(entityName: CoreDataEntityNames.Collection)
        let sortDescriptor = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let predicate = NSPredicate(format: "rowBackdrop != nil")
        fetchRequest.predicate = predicate
        fetchRequest.sortDescriptors = sortDescriptor
        
        let asynchronousFetchRequest = NSAsynchronousFetchRequest(fetchRequest: fetchRequest) { (result) in
            performUIUpdatesOnMain({
                if let collections = result.finalResult as? [Collection] {
                    if collections.count > 0 {
                        let filteredCollection = Array(Set(collections))
                        self.collections = filteredCollection
                        self.tableView.hidden = false
                        self.tableView.reloadData()
                    }
                }
            })
        }
        
        stack.context.performBlock {
            do {
                try self.stack.context.executeRequest(asynchronousFetchRequest)
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
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        fetchCollection()
        refreshControl.endRefreshing()
    }
}

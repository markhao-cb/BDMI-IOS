//
//  MyListViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/31/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import TransitionTreasury
import TransitionAnimation

class MyListViewController: BDMIViewController {

    //MARK: Properties
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var favoriteMovies : [TMDBMovie]?
    var watchedMovies : [TMDBMovie]?
    
    
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        placeHolderLabel = createPlaceHolderLabel("No Results")
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = true
        segmentControl.enabled = Utilities.isLoggedIn()
        if Utilities.isLoggedIn() {
            changeTextForLabel(placeHolderLabel!, text: "No Results")
            let barItem = UIBarButtonItem(title: "Sign Out", style: .Plain, target: self, action: #selector(signInOrOutBtnClicked))
            navigationItem.rightBarButtonItem = barItem
            getLists()
        } else {
            changeTextForLabel(placeHolderLabel!, text: "Please Sign In First.")
            let barItem = UIBarButtonItem(title: "Sign In", style: .Plain, target: self, action: #selector(signInOrOutBtnClicked))
            navigationItem.rightBarButtonItem = barItem
        }
        
    }
    
    //MARK: IBAction
    @IBAction func segmentControlChanged(sender: AnyObject) {
        if segmentControl.selectedSegmentIndex == 0 {
            if let favoriteMovies = favoriteMovies {
                tableView.hidden = (favoriteMovies.count == 0)
            } else {
                tableView.hidden = false
            }
        } else {
            if let watchedMovies = watchedMovies {
                tableView.hidden = (watchedMovies.count == 0)
            } else {
                tableView.hidden = false
            }
        }
        self.tableView.reloadData()
    }
    
    func signInOrOutBtnClicked() {
        if !Reachability.isConnectedToNetwork(){
            showAlertViewWith("Oops", error: "Internet Disconnected", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            return
        }
        if Utilities.isLoggedIn() {
            showAlertViewWith("Sign Out", error: "Are you sure you want to sign out?", type: .AlertViewWithTwoButtons, firstButtonTitle: "Sign Out", firstButtonHandler: {
                performUIUpdatesOnMain({
                    self.resetUserInfo()
                    let homeVC = self.storyboard?.instantiateViewControllerWithIdentifier("BDMIHomeViewController")
                    self.presentViewController(homeVC!, animated: true, completion: nil)
                })
                }, secondButtonTitle: "Cancel", secondButtonHandler: nil)
        } else {
            invokeLoginVCFrom(self, toViewController: nil)
        }
        
    }
    
    //MARK: Helper
    private func resetUserInfo() {
        TMDBClient.sharedInstance.sessionID = nil
        TMDBClient.sharedInstance.userID = nil
        TMDBClient.sharedInstance.requestToken = nil
        Utilities.userDefault.removeObjectForKey("UserID")
        Utilities.userDefault.removeObjectForKey("SessionID")
        Utilities.userDefault.removeObjectForKey("RequestToken")
    }
}

    //MARK: Networking Methods
extension MyListViewController {
    private func getLists() {
        if !Reachability.isConnectedToNetwork(){
            showAlertViewWith("Oops", error: "Internet Disconnected", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            return
        }
        getFavoriteMovies()
        getWatchedMovies()
    }
    
    private func getFavoriteMovies() {
        Utilities.appDelegate.setNewworkActivityIndicatorVisible(true)
        TMDBClient.sharedInstance.getFavoriteMovies { (movies, error) in
            performUIUpdatesOnMain({
                Utilities.appDelegate.setNewworkActivityIndicatorVisible(false)
                if let movies = movies {
                    self.favoriteMovies = movies
                    self.tableView.hidden = (movies.count == 0)
                    self.tableView.reloadData()
                } else {
                    print(error)
                    showAlertViewWith("Oops", error: (error?.localizedDescription)!, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                }
            })
        }
    }
    
    private func getWatchedMovies() {
        Utilities.appDelegate.setNewworkActivityIndicatorVisible(true)
        TMDBClient.sharedInstance.getWatchlistMovies { (movies, error) in
            performUIUpdatesOnMain({
                Utilities.appDelegate.setNewworkActivityIndicatorVisible(false)
                if let movies = movies {
                    self.watchedMovies = movies
                    self.tableView.reloadData()
                } else {
                    print(error)
                    showAlertViewWith("Oops", error: (error?.localizedDescription)!, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                }
            })
        }
    }
}


    //MARK: UITableView Delegate && Data Source
extension MyListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if segmentControl.selectedSegmentIndex == 0 {
            if let movies = favoriteMovies {
                return movies.count
            } else {
                return 0
            }
        } else {
            if let movies = watchedMovies {
                return movies.count
            } else {
                return 0
            }
        }
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BDMIMovieCollectionsTableViewCell") as! BDMIMovieCollectionsTableViewCell
        cell.configCell()
        var movie: TMDBMovie?
        if segmentControl.selectedSegmentIndex == 0 {
            movie = favoriteMovies![indexPath.row]
        } else {
            movie = watchedMovies![indexPath.row]
        }
        cell.backdropIV.kf_showIndicatorWhenLoading = true
        cell.backdropIV.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.BackdropSizes.DetailBackdrop, filePath: movie!.backdropPath!))
        cell.titleLabel.text = movie!.title
        
        return cell
    }
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        let visibleCells = tableView.visibleCells
        
        for case let cell as BDMIMovieCollectionsTableViewCell in visibleCells {
            cell.cellOnTableViewDidScrollOnView(tableView, view: view)
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let movieDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        var movie : TMDBMovie?
        if segmentControl.selectedSegmentIndex == 0 {
            movie = favoriteMovies![indexPath.row]
        } else {
            movie = watchedMovies![indexPath.row]
        }
        movieDetailVC.movieID = movie?.id
        movieDetailVC.moviePosterPath = movie?.posterPath
        movieDetailVC.modalDelegate = self
        tr_presentViewController(movieDetailVC, method: TRPresentTransitionMethod.Fade)
    }
}

//MARK: UI Related Methods
extension MyListViewController {
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        getWatchedMovies()
        getFavoriteMovies()
        refreshControl.endRefreshing()
    }
}

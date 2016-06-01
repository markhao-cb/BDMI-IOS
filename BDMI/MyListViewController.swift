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

class MyListViewController: UIViewController {

    //MARK: Properties
    @IBOutlet weak var segmentControl: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    var favoriteMovies : [TMDBMovie]?
    var watchedMovies : [TMDBMovie]?
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        createPlaceHolderLabel("No Results.")
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "logout"), style: .Plain, target: self, action: #selector(logoutBtnClicked))
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.hidden = true
        getFavoriteMovies()
        getWatchedMovies()
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
    
    func logoutBtnClicked() {
        resetUserInfo()
        let loginVC = self.storyboard?.instantiateViewControllerWithIdentifier("LoginVC") as! LoginViewController
        self.presentViewController(loginVC, animated: true, completion: nil)
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
    private func getFavoriteMovies() {
        TMDBClient.sharedInstance.getFavoriteMovies { (movies, error) in
            performUIUpdatesOnMain({ 
                if let movies = movies {
                    self.favoriteMovies = movies
                    self.tableView.hidden = (movies.count == 0)
                    self.tableView.reloadData()
                } else {
                    print(error)
                }
            })
        }
    }
    
    private func getWatchedMovies() {
        TMDBClient.sharedInstance.getWatchlistMovies { (movies, error) in
            performUIUpdatesOnMain({ 
                if let movies = movies {
                    self.watchedMovies = movies
                    self.tableView.reloadData()
                } else {
                    print(error)
                }
            })
        }
    }
}


    //MARK: UITableView Delegate && Data Source
extension MyListViewController: UITableViewDelegate, UITableViewDataSource, ModalTransitionDelegate {
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

//
//  MovieDetailViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import Kingfisher
import TransitionTreasury
import TransitionAnimation
import CoreData

class MovieDetailViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var movieID : Int?
    var moviePosterPath: String?
    var movie : Movie?
    var blurEffectView : UIVisualEffectView?
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    weak var modalDelegate: ModalViewControllerDelegate?
    var isFavorite = false
    var isWatchlist = false
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBackgroundView()
        if let id = movieID {
            if case let movie as Movie = Utilities.objectSavedInCoreData(id, entity: CoreDataEntityNames.Movie) {
                self.movie = movie
            } else {
                getMovieDetailsById(id)
            }
            
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        checkIfLiked()
        checkIfWatched()
    }
}

//MARK: CoreData Methods 
extension MovieDetailViewController {
    
}


//MARK: Networking Methods
extension MovieDetailViewController {
    private func checkIfLiked() {
        
        TMDBClient.sharedInstance.getFavoriteMovies { (movies, error) in
            if let movies = movies {
                
                for movie in movies {
                    if movie.id == self.movieID {
                        self.isFavorite = true
                    }
                }
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    private func checkIfWatched() {

        TMDBClient.sharedInstance.getWatchlistMovies { (movies, error) in
            if let movies = movies {
                
                for movie in movies {
                    if movie.id == self.movieID {
                        self.isWatchlist = true
                    }
                }
                performUIUpdatesOnMain {
                    self.tableView.reloadData()
                }
            } else {
                print(error)
            }
        }
    }
    
    func getMovieDetailsById(id: Int) {
        TMDBClient.sharedInstance.getMovieDetailBy(id) { (result, error) in
            performUIUpdatesOnMain({ 
                guard error == nil else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.movie = Utilities.createNewMovie(result!)
                self.tableView.reloadData()
            })
        }
    }
    
    func getDetailPosterByPath(path: String) {
        TMDBClient.sharedInstance.taskForGETImage(TMDBClient.PosterSizes.DetailPoster, filePath: path) { (imageData, error) in
            
        }
    }
}

//MARK: UITableView Delegate && DataSource Method
extension MovieDetailViewController : UITableViewDelegate, UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderSectionCell") as! MovieDetailCellForHeaderSection
            cell.likeBtn.selected = isFavorite
            cell.watchBtn.selected = isWatchlist
            cell.configCell()
            return cell
        case 1:
            let cell = tableView.dequeueReusableCellWithIdentifier("TitleSectionCell") as! MovieDetailCellForTitleSection
            cell.titleLbl.text = movie?.title
            cell.ratingLbl.text = "Rating: \(movie!.voteAverage!)"
            cell.runtimeLbl.text = "Runtime: \(movie!.runtime!)mins"
            cell.releaseDateLbl.text = "Year: \(movie!.releaseDate!)"
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 44
        case 1:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return view.frame.height - 100
        }
        return 0
    }
    
    
    
    func  scrollViewDidScroll(scrollView: UIScrollView) {
        blurEffectView?.alpha = min(1,scrollView.contentOffset.y / 200)
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }
    
    @IBAction func watchButtonClicked(sender: AnyObject) {
        let shouldWatchlist = !isWatchlist
        
        TMDBClient.sharedInstance.postToWatchlist(movieID!, watchlist: shouldWatchlist) { (statusCode, error) in
            if let error = error {
                showAlertViewWith("Oops", error: "Could Not Add to Watched List. Error: \(error.localizedDescription)", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            } else {
                if statusCode == 1 || statusCode == 12 || statusCode == 13 {
                    self.isWatchlist = shouldWatchlist
                    performUIUpdatesOnMain {
                        self.tableView.reloadData()
                    }
                } else {
                    showAlertViewWith("Oops", error: "Could Not Add to Watched List.", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                }
            }
        }
    }
    
    @IBAction func likeButtonClicked(sender: AnyObject) {
        let shouldFavorite = !isFavorite
        
        TMDBClient.sharedInstance.postToFavorites(movieID!, favorite: shouldFavorite) { (statusCode, error) in
            if let error = error {
                showAlertViewWith("Oops", error: "Could Not Like It. Error: \(error.localizedDescription)", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
            } else {
                if statusCode == 1 || statusCode == 12 || statusCode == 13 {
                    self.isFavorite = shouldFavorite
                    performUIUpdatesOnMain {
                        self.tableView.reloadData()
                    }
                } else {
                    showAlertViewWith("Oops", error: "Could Not Like It.", type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                }
            }
        }
    }
}

//MARK: UI Related Methods
extension MovieDetailViewController {
    
    private func setupBackgroundView() {
        
        backgroundImageView.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.DetailPoster, filePath: moviePosterPath!), placeholderImage: nil, optionsInfo:[.Transition(ImageTransition.Fade(1.0))], progressBlock: nil) { (image, error, cacheType, imageURL) in
                performUIUpdatesOnMain({
                    self.addBlurViewTo(self.backgroundImageView)
                })
        }
    }
    
    private func addBlurViewTo(view:UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        if let blurEffectView = blurEffectView {
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            blurEffectView.alpha = 0
            view.addSubview(blurEffectView)
        }
    }
}
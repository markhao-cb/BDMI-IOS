//
//  CollectionMoviesViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/31/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import Kingfisher
import TransitionTreasury
import TransitionAnimation

class CollectionMoviesViewController: BDMIViewController {
    
    //MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundBlurView: UIImageView!
    @IBOutlet weak var navView: UIView!
    
    var collection : Collection?
    var collectionMovies = [Movie]()
    var stack = Utilities.appDelegate.stack
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let collection = collection {
            let movies = collection.movies?.allObjects as? [Movie]
            if movies!.count == 0 {
                getMoviesForCollection(collection)
            } else {
                collectionMovies = Array(Set(movies!))
            }
            setupBlurView()
            setupNavView()
        }
    }
    
    //MARK: IBActions
    @IBAction func backBtnClicked(sender: AnyObject) {
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }

}

//MARK: Networking

extension CollectionMoviesViewController {
    private func getMoviesForCollection(collection: Collection) {
        Utilities.appDelegate.setNewworkActivityIndicatorVisible(true)
        TMDBClient.sharedInstance.getCollectionlBy(Int(collection.id!), completionHandlerForGetCollection: { (result, error) in
            performUIUpdatesOnMain({ 
                Utilities.appDelegate.setNewworkActivityIndicatorVisible(false)
                guard (error == nil) else {
                    print("Error while getting collection. Error: \(error?.localizedDescription)")
                    showAlertViewWith("Oops", error: (error?.localizedDescription)!, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                if let parts = result!.parts {
                    let collectionMovies = TMDBMovie.moviesFromResults(parts)
                    self.perfetchMovies(collectionMovies, forCollection: collection)
                }
            })
        })
        
    }
    
    private func perfetchMovies(movies: [TMDBMovie],  forCollection collection: Collection) {
        for movie in movies {
            //Check if the movie is already saved.
            if let savedMovie = stack.objectSavedInCoreData(movie.id, entity: CoreDataEntityNames.Movie) as? Movie {
                
                self.collectionMovies.append(savedMovie)
                self.collectionView.reloadData()
            } else {
                
                //Movie's not saved. Get movie details from API
                Utilities.appDelegate.setNewworkActivityIndicatorVisible(true)
                TMDBClient.sharedInstance.getMovieDetailBy(movie.id, completionHandlerForGetDetail: { (movieResult, error) in
                    performUIUpdatesOnMain({
                        Utilities.appDelegate.setNewworkActivityIndicatorVisible(false)
                        if let error = error {
                            print("Prefetch Failed. \(error.domain)")
                            showAlertViewWith("Oops", error: (error.localizedDescription), type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                        } else {
                            //Create new movie and save to coredata
                            let newMovie = self.stack.createNewMovie(movieResult!)
                            collection.addMoviesObject(newMovie)
                            self.collectionMovies.append(newMovie)
                            self.collectionView.reloadData()
                        }
                    })
                })
            }
        }
    }
}

//MARK: CollectionDelegate and DataSource
extension CollectionMoviesViewController : UICollectionViewDataSource, UICollectionViewDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return collectionMovies.count + 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionCell", forIndexPath: indexPath) as!MovieCeollectionCell
        cell.configCell()
        if indexPath.section == 0 {
            cell.overviewView.hidden = false
            cell.posterImageView.hidden = true
            cell.titleLabel.text = collection!.name
            cell.overviewLabel.text = collection!.overview
        } else {
            cell.overviewView.hidden = true
            cell.posterImageView.hidden = false
            let movie = collectionMovies[indexPath.section - 1]
            cell.posterImageView.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.DetailPoster, filePath: movie.posterPath!), placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1.5))], progressBlock: nil, completionHandler: nil)
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        let movieDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        let movie = collectionMovies[indexPath.section - 1]
        movieDetailVC.movieID = Int(movie.id!)
        movieDetailVC.moviePosterPath = movie.posterPath
        movieDetailVC.modalDelegate = self
        tr_presentViewController(movieDetailVC, method: TRPresentTransitionMethod.Fade)
    }
    
}

//MARK: UI related methods
extension CollectionMoviesViewController {
    private func setupNavView() {
        navView.backgroundColor = Utilities.backgroundColor
        
    }
    
    private func setupBlurView() {
        backgroundBlurView.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.DetailPoster, filePath: collection!.detailPosterPath!), placeholderImage: nil, optionsInfo:nil, progressBlock: nil, completionHandler: nil)
        addBlurViewTo(backgroundBlurView)
    }
    
    private func addBlurViewTo(view:UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Dark)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.alpha = 0.5
        blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        view.addSubview(blurEffectView)
    }
}
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

class CollectionMoviesViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backgroundBlurView: UIImageView!
    @IBOutlet weak var navView: UIView!
    
    var collection : Collection?
    var collectionMovies : [Movie]?
    
    var tr_presentTransition: TRViewControllerTransitionDelegate?
    weak var modalDelegate: ModalViewControllerDelegate?
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        if let collection = collection {
            collectionMovies = collection.movies?.allObjects as? [Movie]
            setupBlurView()
            setupNavView()
        }
    }
    
    //MARK: IBActions
    @IBAction func backBtnClicked(sender: AnyObject) {
        modalDelegate?.modalViewControllerDismiss(callbackData: nil)
    }

}

extension CollectionMoviesViewController : UICollectionViewDataSource, UICollectionViewDelegate, ModalTransitionDelegate {
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        if let movies = collectionMovies {
            return movies.count + 1
        }
        return 0
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
            if let movies = collectionMovies {
                let movie = movies[indexPath.section - 1]
                cell.posterImageView.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.DetailPoster, filePath: movie.posterPath!), placeholderImage: nil, optionsInfo: [.Transition(ImageTransition.Fade(1.5))], progressBlock: nil, completionHandler: nil)
            }
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.section == 0 {
            return
        }
        let movieDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        let movie = collectionMovies![indexPath.section - 1]
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
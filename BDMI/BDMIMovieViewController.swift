//
//  BDMIMovieViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import Kingfisher

class BDMIMovieViewController: UIViewController {
    
    
    //MARK: Propertites
    @IBOutlet weak var tableView: UITableView!
    var nowShowingMovies : [TMDBMovie]?
    var upcomingMovies : [TMDBMovie]?
    var popularMovies : [TMDBMovie]?
    var storedOffsets = [Int: CGFloat]()
    
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        getNowShowingMovies()
        getPopularMovies()
        geUpcomingMovies()
    }
    
}


//MARK: UITableView Delegate and DataSource
extension BDMIMovieViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MovieTableViewCell") as! MovieTableViewCell
        switch indexPath.row {
            //NOW SHOWING
        case 0:
            changeTextForLabel(cell.sectionLabel, text: "Now Showing")
            break
            
            //COMING SOON
        case 1:
            changeTextForLabel(cell.sectionLabel, text: "Coming Soon")
            break
            
            //POPULAR
        case 2:
            changeTextForLabel(cell.sectionLabel, text: "Popular")
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? MovieTableViewCell else {
            return
        }
        
        tableViewCell.setCollectionViewDataSourceDelegate(self, forRow: indexPath.row)
        tableViewCell.collectionViewOffset = storedOffsets[indexPath.row] ?? 0
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        guard let tableViewCell = cell as? MovieTableViewCell else {
            return
        }
        storedOffsets[indexPath.row] = tableViewCell.collectionViewOffset
    }
    
}


//MARK: UICollectionView Delegate and DataSource
extension BDMIMovieViewController : UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch collectionView.tag {
            //NOW SHOWING
        case 0:
            if let movies = nowShowingMovies {
                return min(movies.count, 20)
            }
            break
            
            //COMGING SOON
        case 1:
            if let movies = upcomingMovies {
                return min(movies.count, 20)
            }
            break
            
            //POPULAR
        case 2:
            if let movies = popularMovies {
                return min(movies.count, 20)
            }
            break
            
        default:
            break
        }
        return 0
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("MovieCollectionViewCell", forIndexPath: indexPath) as! MovieCollectionViewCell
        var movie : TMDBMovie?
        switch collectionView.tag {
        case 0: /* NOW SHOWING */
            if let movies = nowShowingMovies {
                movie = movies[indexPath.row]
            }
            break
        case 1: /* COMGING SOON */
            if let movies = upcomingMovies {
                movie = movies[indexPath.row]
            }
            break
        case 2: /* POPULAR */
            if let movies = popularMovies {
                movie = movies[indexPath.row]
            }
            break
        default: break
        }
        
        let activityIndicatorView = NVActivityIndicatorView.init(frame: CGRectMake(0, 0, cell.frame.width / 4, cell.frame.width / 4), type: .BallSpinFadeLoader, color: UIColor.grayColor(), padding: nil)
        activityIndicatorView.center = cell.center
        activityIndicatorView.startAnimation()
        cell.addSubview(activityIndicatorView)
        
        if let imagePath = movie?.posterPath {
            cell.imageView.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.RowPoster, filePath: imagePath),
                                              placeholderImage: nil,
                                              optionsInfo: [.Transition(ImageTransition.Fade(1))], progressBlock: nil, completionHandler: { image, error, cacheType, imageURL in
                                                performUIUpdatesOnMain({
                                                    activityIndicatorView.stopAnimation()
                                                    cell.imageView.alpha = 1.0
                                                })
                                                
            })
        }
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let movieDetailVC = self.storyboard?.instantiateViewControllerWithIdentifier("MovieDetailViewController") as! MovieDetailViewController
        var movie : TMDBMovie?
        switch collectionView.tag {
        case 0: /* NOW SHOWING */
            if let movies = nowShowingMovies {
                movie = movies[indexPath.row]
            }
            break
        case 1: /* COMGING SOON */
            if let movies = upcomingMovies {
                movie = movies[indexPath.row]
            }
            break
        case 2: /* POPULAR */
            if let movies = popularMovies {
                movie = movies[indexPath.row]
            }
            break
        default: break
        }
        movieDetailVC.movie = movie
        navigationController?.pushViewController(movieDetailVC, animated: true)
    }
}

//MARK: Networking Methods
extension BDMIMovieViewController {
    func getNowShowingMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.NowPlaying) { (result, error) in
            performUIUpdatesOnMain({ 
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.nowShowingMovies = result!
                self.tableView.reloadData()
            })
        }
    }
    
    func geUpcomingMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.UpComing) { (result, error) in
            performUIUpdatesOnMain({
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.upcomingMovies = result
                self.tableView.reloadData()
            })
        }
    }
    
    func getPopularMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.Popular) { (result, error) in
            performUIUpdatesOnMain({
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.popularMovies = result
                self.tableView.reloadData()
            })
        }
    }
    
    func getTopRatedMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.TopRated) { (result, error) in
            performUIUpdatesOnMain({
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.tableView.reloadData()
            })
        }
    }
}

//MARK: Helper Methods
extension BDMIMovieViewController {
    private func changeTextForLabel(label: UILabel, text: String) {
        label.text = text
        label.sizeToFit()
    }
}

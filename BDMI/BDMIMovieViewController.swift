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
import CoreData

class BDMIMovieViewController: UIViewController {
    
    
    //MARK: Propertites
    @IBOutlet weak var tableView: UITableView!
    var nowShowingMovies : [TMDBMovie]?
    var upcomingMovies : [TMDBMovie]?
    var popularMovies : [TMDBMovie]?
    var topRatedMovies : [TMDBMovie]?
    var storedOffsets = [Int: CGFloat]()
    
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        loadData()
        addRefreshControl()
    }
    
    func refresh(refreshControl: UIRefreshControl) {
        loadData()
        refreshControl.endRefreshing()
    }
    
}

//MARK: UI related and navigation methods
extension BDMIMovieViewController {
    private func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refresh), forControlEvents: .ValueChanged)
        tableView.addSubview(refreshControl)
    }
}


//MARK: UITableView Delegate and DataSource
extension BDMIMovieViewController : UITableViewDelegate, UITableViewDataSource {
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
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
            //TOP RATED
        case 3:
            changeTextForLabel(cell.sectionLabel, text: "Top Rated")
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
            //TOP RATED
        case 3:
            if let movies = topRatedMovies {
                return min(movies.count, 20)
            }
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
        case 3: /* TOP RATED */
            if let movies = topRatedMovies {
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
        case 3: /* TOP RATED */
            if let movies = topRatedMovies {
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
    private func loadData() {
        getNowShowingMovies()
        getPopularMovies()
        geUpcomingMovies()
        getTopRatedMovies()
    }
    
    private func getNowShowingMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.NowPlaying) { (result, error) in
            performUIUpdatesOnMain({ 
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.nowShowingMovies = result!
                self.tableView.reloadData()
                print("Load Now Showing Movies Successfully")
            })
        }
    }
    
    private func geUpcomingMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.UpComing) { (result, error) in
            performUIUpdatesOnMain({
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.upcomingMovies = result
                self.tableView.reloadData()
                self.perfetchMovieDetails(result!)
                print("Load Upcoming Movies Successfully")
            })
        }
    }
    
    private func getPopularMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.Popular) { (result, error) in
            performUIUpdatesOnMain({
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.popularMovies = result
                self.tableView.reloadData()
                print("Load Popular Movies Successfully")
            })
        }
    }
    
    private func getTopRatedMovies() {
        TMDBClient.sharedInstance.getMoviesBy(TMDBClient.Methods.TopRated) { (result, error) in
            performUIUpdatesOnMain({
                guard (error == nil) else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.topRatedMovies = result
                self.tableView.reloadData()
                print("Load Top Rated Movies Successfully")
            })
        }
    }
    
    private func perfetchMovieDetails(movies: [TMDBMovie]) {
        for movie in movies {
            if let _ = savedInCoreData(movie.id, entity: CoreDataEntityNames.Movie) as? Movie {} else {
                TMDBClient.sharedInstance.getMovieDetailBy(movie.id, completionHandlerForGetDetail: { (result, error) in
                    if let error = error {
                        print("Prefetch Failed. \(error.domain)")
                    } else {
                        self.createNewMovie(result!)
                    }
                })
            }
        }
    }
}

//MARK: CoreData Methods
extension BDMIMovieViewController {
    private func savedInCoreData(id: Int, entity: String) -> AnyObject? {
        let fetchRequest = NSFetchRequest(entityName: entity)
        let predicate = NSPredicate(format: "id = %d", id)
        fetchRequest.predicate = predicate
        do {
            let result = try Utilities.appDelegate.stack.context.executeFetchRequest(fetchRequest)
            return result.first
        } catch {
            return nil
        }
//        var error: NSError? = nil
//        let count = Utilities.appDelegate.stack.context.countForFetchRequest(fetchRequest, error: &error)
//        if let _ = error {
//            return false
//        } else {
//            return count != 0
//        }
    }
    
    private func createNewMovie(movie: TMDBMovie) -> Movie {
        let id = movie.id
        let title = movie.title
        var posterPath: NSURL? = nil
        if let path = movie.posterPath {
            posterPath = TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.RowPoster, filePath: path)
        }
        let overview = movie.overview
        let voteAverage = movie.voteAverage
        let voteCount = movie.voteCount
        let runtime = movie.runtime
        let popularity = movie.popularity
        let releaseDate = movie.releaseYear
        
        let newMovie = Movie(id: id, title: title, posterPath: posterPath, overview: overview, voteAverage: voteAverage, voteCount: voteCount, runtime: runtime, releaseDate: releaseDate, popularity: popularity, context: Utilities.appDelegate.stack.context)
        print("New Movie Created!")
        
        // Create Collection From Movie Details
        if let collectionData = movie.belongsToCollection {
            let collection = TMDBCollection.init(dictionary: collectionData)
            if let savedCollection = savedInCoreData(collection.id, entity: CoreDataEntityNames.Collection) as? Collection {
                savedCollection.addMoviesObject(newMovie)
            } else {
                let newCollection = createNewCollection(collection)
                newCollection.addMoviesObject(newMovie)
            }
        }
        return newMovie
    }
    
    private func createNewCollection(collection: TMDBCollection) -> Collection {
        let name = collection.name
        let id = collection.id
        var backdropPath: NSURL? = nil
        if let path = collection.backdropPath {
            backdropPath = TMDBClient.sharedInstance.createUrlForImages(TMDBClient.BackdropSizes.RowBackdrop, filePath: path)
        }
        let newCollection = Collection(name: name, id: id, backdropPath: backdropPath, context: Utilities.appDelegate.stack.context)
        print("New Collection Created!")
        return newCollection
    }
}

//MARK: Helper Methods
extension BDMIMovieViewController {
    private func changeTextForLabel(label: UILabel, text: String) {
        label.text = text
        label.sizeToFit()
    }
}

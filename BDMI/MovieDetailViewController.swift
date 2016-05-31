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

class MovieDetailViewController: UIViewController {
    
    //MARK: Properties
    @IBOutlet weak var tableView: UITableView!
    var movie : TMDBMovie?
    var blurEffectView : UIVisualEffectView?
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    weak var modalDelegate: ModalViewControllerDelegate?
    
    //MARK: Life Circle
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBarHidden = true
        setupBackgroundView()
        if let movie = movie {
            getMovieDetailsById(movie.id)
        }
        
    }
}


//MARK: Networking Methods
extension MovieDetailViewController {
    func getMovieDetailsById(id: Int) {
        TMDBClient.sharedInstance.getMovieDetailBy(id) { (result, error) in
            performUIUpdatesOnMain({ 
                guard error == nil else {
                    showAlertViewWith("Oops", error: error!.domain, type: .AlertViewWithOneButton, firstButtonTitle: "OK", firstButtonHandler: nil, secondButtonTitle: nil, secondButtonHandler: nil)
                    return
                }
                self.movie = result
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
        if section == 0 {
            return 1
        }
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("HeaderSectionCell") as! MovieDetailCellForHeaderSection
            cell.configCell()
            return cell
        default:
            return UITableViewCell()
        }
    }
    
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clearColor()
        return headerView
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 1 {
            return view.frame.height - 200
        }
        return 0
    }
    
    
    
    func  scrollViewDidScroll(scrollView: UIScrollView) {
        
    }
    
    @IBAction func backButtonClicked(sender: AnyObject) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func watchButtonClicked(sender: AnyObject) {
    }
    
    @IBAction func likeButtonClicked(sender: AnyObject) {
    }
}

//MARK: UI Related Methods
extension MovieDetailViewController {
    
    private func setupBackgroundView() {
        configKingfisher(backgroundImageView)
        backgroundImageView.kf_setImageWithURL(TMDBClient.sharedInstance.createUrlForImages(TMDBClient.PosterSizes.DetailPoster, filePath: movie!.posterPath!), placeholderImage: nil, optionsInfo:[.Transition(ImageTransition.Fade(1.0))], progressBlock: nil) { (image, error, cacheType, imageURL) in
                performUIUpdatesOnMain({
                    self.addBlurViewTo(self.backgroundImageView)
                })
        }
    }
    
    private func addBlurViewTo(view:UIView) {
        let blurEffect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        blurEffectView = UIVisualEffectView(effect: blurEffect)
        if let blurEffectView = blurEffectView {
            blurEffectView.frame = view.bounds
            blurEffectView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
            blurEffectView.alpha = 0
            view.addSubview(blurEffectView)
        }
    }
}
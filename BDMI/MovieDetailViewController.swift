//
//  MovieDetailViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class MovieDetailViewController: UIViewController {
    
    var movie : TMDBMovie?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
            })
        }
    }
}
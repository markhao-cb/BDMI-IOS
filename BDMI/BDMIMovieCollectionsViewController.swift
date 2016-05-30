//
//  BDMIMovieCollectionsViewController.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit


class BDMIMovieCollectionsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    var collections : [TMDBCollection]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
}

//MARK: Networking Methods
extension BDMIMovieCollectionsViewController {
//    private getCollections
}


//MARK: UITableView Delegate && DataSource
extension BDMIMovieCollectionsViewController : UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("BDMIMovieCollectionsTableViewCell") as! BDMIMovieCollectionsTableViewCell
        return cell
    }
}
//
//  MovieDetailCellForOverview.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/31/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class MovieDetailCellForOverview: UITableViewCell {

    @IBOutlet weak var overviewLbl: UILabel!
    
    func configCell() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
}

//
//  MovieDetailCellForTitleSection.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/30/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class MovieDetailCellForTitleSection: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var runtimeLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    @IBOutlet weak var releaseDateLbl: UILabel!
    
    func configCell() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
}

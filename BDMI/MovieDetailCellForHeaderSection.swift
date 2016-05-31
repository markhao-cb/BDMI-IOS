//
//  MovieDetailCellForHeaderSection.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/30/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class MovieDetailCellForHeaderSection: UITableViewCell {
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var watchBtn: UIButton!
    func configCell() {
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3)
    }
}

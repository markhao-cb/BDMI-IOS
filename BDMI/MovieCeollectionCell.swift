//
//  MovieCeollectionCell.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/31/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class MovieCeollectionCell: UICollectionViewCell {

    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var overviewView: UIView!
    @IBOutlet weak var overviewLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    
    func configCell() {
        self.layer.cornerRadius = 15
        posterImageView.layer.cornerRadius = 15
        overviewView.layer.cornerRadius = 15
        overviewView.backgroundColor = Utilities.backgroundColor
    }
}

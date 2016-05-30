//
//  BDMIMovieCollectionsTableViewCell.swift
//  BDMI
//
//  Created by Yu Qi Hao on 5/29/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class BDMIMovieCollectionsTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var backdropIV: UIImageView!
    
    func cellOnTableViewDidScrollOnView(tableView: UITableView, view: UIView) {
        let rectInSuperview = tableView.convertRect(self.frame, toView: view)
        
        let distanceFromCenter = CGRectGetHeight(view.frame) / 2 - CGRectGetMinY(rectInSuperview)
        let difference = CGRectGetHeight(backdropIV.frame) - CGRectGetHeight(frame)
        let move = (distanceFromCenter / CGRectGetHeight(view.frame)) * difference
        
        var imageRect = backdropIV.frame
        imageRect.origin.y = -(difference/2) + move
        backdropIV.frame = imageRect
    }
    
    func configImageView() {
        backdropIV.clipsToBounds = true
    }
}

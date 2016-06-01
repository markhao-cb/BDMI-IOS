//
//  MovieDetailHeaderSectionView.swfit
//  BDMI
//
//  Created by Yu Qi Hao on 5/30/16.
//  Copyright © 2016 Yu Qi Hao. All rights reserved.
//

import UIKit

class MovieDetailHeaderSectionView: UIView {
    
    @IBOutlet weak var likeBtn: UIButton!
    @IBOutlet weak var watchBtn: UIButton!
    var isHiding : Bool = false
    
    func configView() {
        self.backgroundColor = Utilities.backgroundColor
    }
}

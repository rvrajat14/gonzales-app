//
//  StoreRatingTableViewCell.swift
//  My MM
//
//  Created by Kishore on 02/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class StoreRatingTableViewCell: UITableViewCell {

    @IBOutlet weak var reviewDateLbl: UILabel!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var userImgV: UIImageView!
    @IBOutlet weak var commentsLbl: UILabel!
    
    @IBOutlet weak var userNameLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        if Language.isRTL {
            commentsLbl.textAlignment = .right
        }
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

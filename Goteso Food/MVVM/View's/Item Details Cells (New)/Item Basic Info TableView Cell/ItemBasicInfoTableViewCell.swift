//
//  ItemBasicInfoTableViewCell.swift
//  GotesoMM2
//
//  Created by Kishore on 30/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class ItemBasicInfoTableViewCell: UITableViewCell {

    @IBOutlet weak var tagLbl: AHTagsLabel!
    @IBOutlet weak var productDescriptionLbl: UILabel!
    @IBOutlet weak var productPriceLbl: UILabel!
    @IBOutlet weak var ratingButton: UIButton!
    @IBOutlet weak var productNameLbl: UILabel!
    @IBOutlet weak var productInfoLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

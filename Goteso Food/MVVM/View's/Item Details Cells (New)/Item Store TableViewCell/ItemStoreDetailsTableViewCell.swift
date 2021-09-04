//
//  ItemRestaurantsDetailsTableViewCell.swift
//  GotesoMM2
//
//  Created by Kishore on 30/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class ItemStoreDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var forwardImgV: UIImageView!
    @IBOutlet weak var storeImgV: UIImageView!
    @IBOutlet weak var storeTitleLbl: UILabel!
    @IBOutlet weak var storeDescriptionLbl: UILabel!
    @IBOutlet weak var storeAddressLbl: UILabel!
    @IBOutlet weak var storeNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  ItemsTableCell.swift
//  FirstSwiftTask
//
//  Created by Kishore on 29/05/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class StoreTableCell: UITableViewCell {

    @IBOutlet weak var featuredLbl: UILabel!
    @IBOutlet weak var storeNameLbl: UILabel!
    @IBOutlet weak var imageV: UIImageView!
    
    @IBOutlet weak var closedLbl: UILabel!
    @IBOutlet weak var storeStatusView: UIView!
    
    @IBOutlet weak var storeInfoHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var ratingView: UIView!
    @IBOutlet weak var locationImgV: UIImageView!
    @IBOutlet weak var ratingButton: UIButton!
   
    @IBOutlet weak var storeAddressNameLbl: UILabel!
    @IBOutlet weak var ratingLbl: UILabel!
    
    @IBOutlet weak var storeInfoLbl: UILabel!
    
    
   
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
       closedLbl.text = "z_closed".getLocalizedValue()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

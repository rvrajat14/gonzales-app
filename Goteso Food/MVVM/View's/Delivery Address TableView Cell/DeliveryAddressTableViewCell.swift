//
//  DeliveryAddressTableViewCell.swift
//  Dry Clean City
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class DeliveryAddressTableViewCell: UITableViewCell {

    @IBOutlet weak var sideMenuButton: UIButton!
    @IBOutlet weak var circleImgV: UIImageView!
    @IBOutlet weak var defaultButtonWidthConstraints: NSLayoutConstraint!
   
    @IBOutlet weak var setDefaultCheckBoxButton: UIButton!
   
    @IBOutlet weak var address1Lbl: UILabel!
    @IBOutlet weak var addressTitleLbl: UILabel!
   
     
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  OrderNotificationTableViewCell.swift
//  FoodApplication
//
//  Created by Kishore on 08/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderNotificationTableViewCell: UITableViewCell {

    @IBOutlet weak var couponCodeLbl: UILabel!
    @IBOutlet weak var notificationTimeLbl: UILabel!
    @IBOutlet weak var notificationDescriptionLbl: UILabel!
    @IBOutlet weak var notificationTitleLbl: UILabel!
  
    @IBOutlet weak var imgV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        imgV.layer.cornerRadius = imgV.frame.size.width/2
        imgV.backgroundColor = MAIN_COLOR
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  UserInfoTableCell.swift
//  MY MM Provider APP
//
//  Created by Kishore on 21/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class UserInfoTableCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    
    @IBOutlet weak var callButton: UIButton!
   
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var nameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

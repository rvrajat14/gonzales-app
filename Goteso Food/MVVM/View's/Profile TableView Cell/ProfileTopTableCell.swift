//
//  ProfileTopTableCell.swift
//  Dry Clean City
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ProfileTopTableCell: UITableViewCell {

    @IBOutlet weak var userNumberLbl: UILabel!
    
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

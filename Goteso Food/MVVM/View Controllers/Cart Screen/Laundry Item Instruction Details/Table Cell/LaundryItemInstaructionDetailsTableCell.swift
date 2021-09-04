//
//  LaundryItemInstaructionDetailsTableCell.swift
//  My MM
//
//  Created by Kishore on 23/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class LaundryItemInstaructionDetailsTableCell: UITableViewCell {
    @IBOutlet weak var itemNameLbl: UILabel!
    
    @IBOutlet weak var instructionLbl: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var editButton: UIButton!
    @IBOutlet weak var separatorView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

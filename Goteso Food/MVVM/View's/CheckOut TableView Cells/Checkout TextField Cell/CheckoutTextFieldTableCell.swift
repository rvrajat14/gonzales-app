//
//  CheckoutTextFieldTableCell.swift
//  My MM
//
//  Created by Kishore on 22/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class CheckoutTextFieldTableCell: UITableViewCell {
    @IBOutlet weak var separatorV: UIView!
    
    @IBOutlet weak var infoLbl: UILabel!
    @IBOutlet weak var imagV: UIImageView!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

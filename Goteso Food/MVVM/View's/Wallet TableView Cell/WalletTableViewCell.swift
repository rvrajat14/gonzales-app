//
//  WalletTableViewCell.swift
//  My MM
//
//  Created by Kishore on 18/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class WalletTableViewCell: UITableViewCell {

    @IBOutlet weak var pointsLblWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var msgLbl: UILabel!
    @IBOutlet weak var separatorLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var arrowImg: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

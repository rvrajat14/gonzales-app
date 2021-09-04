//
//  SideMenuTableCell.swift
//  My MM
//
//  Created by Kishore on 05/01/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class SideMenuTableCell: UITableViewCell {

    @IBOutlet weak var valueLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var sideLbl: UILabel!
    @IBOutlet weak var mainV: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

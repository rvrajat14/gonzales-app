//
//  ShimmerTableCell.swift
//  Dry Clean City
//
//  Created by Kishore on 27/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ShimmerTableCell: UITableViewCell {

    @IBOutlet weak var imageLbl: UILabel!
    @IBOutlet weak var lbl1: UILabel!
    
    @IBOutlet weak var lbl2: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  LocalityAreaTableViewCell.swift
//  FoodApplication
//
//  Created by Kishore on 11/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class LocalityAreaTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var locationNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
         titleLbl.text = "y_location_current".getLocalizedValue()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

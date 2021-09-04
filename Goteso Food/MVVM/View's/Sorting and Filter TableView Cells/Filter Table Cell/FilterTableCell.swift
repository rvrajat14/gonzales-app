//
//  FilterTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 30/05/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class FilterTableCell: UITableViewCell {

    @IBOutlet weak var checkBoxImgV: UIImageView!
    @IBOutlet weak var checkBoxButton: UIButton!
    @IBOutlet weak var optionLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  AddInstructionTableViewCell.swift
//  My MM
//
//  Created by Kishore on 27/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class AddInstructionTableViewCell: UITableViewCell {
     
    @IBOutlet weak var fragileLbl: UILabel!
    @IBOutlet weak var fragileCheckBoxbutton: UIButton!
    @IBOutlet weak var detailsSizeLbl: UILabel!
    @IBOutlet weak var detailsUnitTypeLbl: UILabel!
    @IBOutlet weak var detailsTxtField: UITextField!
    @IBOutlet weak var detailsView: UIView!
    @IBOutlet weak var courierDetailsView: UIView!
    @IBOutlet weak var instructionView: UIView!
    @IBOutlet weak var instructionDetailsTxt: UITextField!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var instructionDetailsView: UIView!
    
    @IBOutlet weak var instructionTitleLbl: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

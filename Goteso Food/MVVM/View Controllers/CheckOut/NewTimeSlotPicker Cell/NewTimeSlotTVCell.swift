//
//  NewTimeSlotTVCell.swift
//  Gastro Pub Gonzales
//
//  Created by IOS on 21/07/20.
//  Copyright © 2020 Kishore. All rights reserved.
//

import UIKit

class NewTimeSlotTVCell: UITableViewCell {
    @IBOutlet weak var selectTimeLbl: UILabel!
    @IBOutlet weak var asapView: UIView!
    @IBOutlet weak var asapLbl: UILabel!
    @IBOutlet weak var asapButton: UIButton!
    @IBOutlet weak var ownTimeView: UIView!
    @IBOutlet weak var ownTimeLbl: UILabel!
    @IBOutlet weak var ownTimeSelectionButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        asapView.layer.borderColor = MAIN_COLOR.cgColor
        asapView.layer.borderWidth = 1
        asapView.layer.cornerRadius = asapView.frame.size.height/2
        
        ownTimeView.layer.borderColor = MAIN_COLOR.cgColor
        ownTimeView.layer.borderWidth = 1
        ownTimeView.layer.cornerRadius = asapView.frame.size.height/2
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

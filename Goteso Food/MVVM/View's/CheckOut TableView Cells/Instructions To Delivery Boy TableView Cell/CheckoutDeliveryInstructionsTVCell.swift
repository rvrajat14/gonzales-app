//
//  CheckoutDeliveryInstructionsTVCell.swift
//  FoodApplication
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit
import IQKeyboardManager
class CheckoutDeliveryInstructionsTVCell: UITableViewCell {

    @IBOutlet weak var separatorV: UIView!
    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var instructionTxtView: IQTextView!
    override func awakeFromNib() {
        super.awakeFromNib()
       
        if Language.isRTL {
            
          //  instructionTxtView.semanticContentAttribute = .forceRightToLeft
            
        }
        else
        {
            // instructionTxtView.semanticContentAttribute = .forceLeftToRight
            
        }
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

//
//  CartItemTableViewCell.swift
//  My MM
//
//  Created by Kishore on 25/02/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class CartItemTableViewCell: UITableViewCell {
 @IBOutlet weak var addMItemsButton: UIButton!
    
    @IBOutlet weak var customisedLbl: UILabel!
    @IBOutlet weak var unitLbl: UILabel!
    @IBOutlet weak var itemHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customisedView: UIView!
    @IBOutlet weak var customizedButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var customizedButton: UIButton!
    @IBOutlet weak var setInstructionsButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var totalQuantityLbl: UILabel!
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var itemPriceLbl: UILabel!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var itemImageV: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        quantityView.layer.borderWidth = 1
        quantityView.layer.borderColor = MAIN_COLOR.cgColor
        addButton.setTitle("z_add".getLocalizedValue(), for: .normal)
        customisedLbl.text = "y_cart_customized".getLocalizedValue()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func setLabelHeight(string:String)  {
        itemNameLbl.text = string
        itemHeightConstraint.constant = itemNameLbl.heightForLabel()
    }
}

//
//  LaundryAndSupermarketCartItemTableViewCell.swift
//  My MM
//
//  Created by Kishore on 17/10/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class  ItemTableCell: UITableViewCell {

    @IBOutlet weak var notAvailableLbl: UILabel!
    @IBOutlet weak var itemTitleHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var unitLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var customizedButtonHeight: NSLayoutConstraint!
    @IBOutlet weak var customizedButton: UIButton!
    @IBOutlet weak var itemNotAvailableV: UIView!
    @IBOutlet weak var addMItemsButton: UIButton!
    @IBOutlet weak var itemStatusView: UIView!
    @IBOutlet weak var setInstructionsButton: UIButton!
    @IBOutlet weak var addButton: UIButton!
    
    @IBOutlet weak var separatorView: UIView!
    @IBOutlet weak var totalQuantityLbl: UILabel!
    @IBOutlet weak var quantityView: UIView!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
   
    @IBOutlet weak var itemCategoryLbl: UILabel!
    @IBOutlet weak var itemPriceLbl: UILabel!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var itemImageV: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        notAvailableLbl.text = "y_item_unavailable".getLocalizedValue()
         customizedButton.setTitle("y_cart_customized".getLocalizedValue(), for: .normal)
        addButton.setTitle("z_add".getLocalizedValue(), for: .normal)
        quantityView.layer.borderWidth = 1
        quantityView.layer.borderColor = MAIN_COLOR.cgColor
         itemTitleHeightConstraint.constant  = 0.0
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        itemTitleHeightConstraint.constant  = 0.0
      
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setLabelHeight(string:String)  {
        itemNameLbl.text = string
        itemTitleHeightConstraint.constant = itemNameLbl.heightForLabel()
    }
    
}

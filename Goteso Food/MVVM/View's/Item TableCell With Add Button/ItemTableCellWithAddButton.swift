//
//  SuperMarketItemTableCell.swift
//  My MM
//
//  Created by Kishore on 28/12/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ItemTableCellWithAddButton: UITableViewCell {

    @IBOutlet weak var itemNotAvailableV: UIView!
    
    @IBOutlet weak var itemLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var itemStatusView: UIView!
     
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
    
    @IBOutlet weak var notAvailableLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        notAvailableLbl.text = "y_item_unavailable".getLocalizedValue()
         
        addButton.setTitle("z_add".getLocalizedValue(), for: .normal)
       quantityView.layer.borderColor = MAIN_COLOR.cgColor
        quantityView.layer.borderWidth = 1
        itemLblHeightConstraint.constant = 0.0
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
         itemLblHeightConstraint.constant = 0.0
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func setLabelHeight(string:String) {
        itemNameLbl.text = string
        itemLblHeightConstraint.constant = itemNameLbl.heightForLabel()
    }
    
}

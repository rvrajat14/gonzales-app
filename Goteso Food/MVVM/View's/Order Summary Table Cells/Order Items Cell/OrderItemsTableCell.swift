//
//  OrderItemsTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 07/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderItemsTableCell: UITableViewCell {

    @IBOutlet weak var priceLblWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var mainTitleLblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var mainTitleLbl: UILabel!
  //  @IBOutlet weak var instructionView: UIView!
    
    @IBOutlet weak var nameLblHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var separatorV: UIView!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var titleLbl: UILabel!
  // @IBOutlet weak var instructionButton: UIButton!
    @IBOutlet weak var categoryTitleLbl: UILabel!
    
    @IBOutlet weak var amountLblHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var titleLblHeightConstraints: NSLayoutConstraint!
  //  @IBOutlet weak var instructionButtonHeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var totalPriceLbl: UILabel!
    @IBOutlet weak var numberOfItemsLbl: UILabel!
    @IBOutlet weak var itemNameLbl: UILabel!
    @IBOutlet weak var itemImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
         titleLbl.text = "z_title".getLocalizedValue()
        amountLbl.text = "z_amount".getLocalizedValue()
        
        if Language.isRTL {
            
            totalPriceLbl.textAlignment = .left
            itemNameLbl.textAlignment = .right
            categoryTitleLbl.textAlignment = .right
            titleLbl.textAlignment = .right
            amountLbl.textAlignment = .left
            numberOfItemsLbl.textAlignment = .right
        }
        
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLbl.text = ""
        categoryTitleLbl.text = ""
        
    }
    
    func setLableHeight(string:String)  {
        itemNameLbl.text = string
        nameLblHeightConstraint.constant = itemNameLbl.heightForLabel()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

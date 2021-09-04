//
//  OrderTableViewCell.swift
//  Dry Clean City
//
//  Created by Kishore on 05/06/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderTableViewCell: UITableViewCell {

    @IBOutlet weak var priceLblWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var statusWidthConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var storeNameLbl: UILabel!
    
    @IBOutlet weak var storeImageV: UIImageView!
    
    @IBOutlet weak var orderStatusLbl: UILabel!
     
    @IBOutlet weak var orderDateLbl: UILabel!
    @IBOutlet weak var orderPriceLbl: UILabel!
    @IBOutlet weak var orderNumberLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
         priceLblWidthConstraints.constant =  orderPriceLbl.optimalWidth + 30
        super.prepareForReuse()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

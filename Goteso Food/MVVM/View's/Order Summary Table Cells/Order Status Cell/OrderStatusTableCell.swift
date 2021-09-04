//
//  OrderStatusTableCell.swift
//  My MM
//
//  Created by Kishore on 16/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class OrderStatusTableCell: UITableViewCell {

    @IBOutlet weak var titleLbl: UILabel!
    @IBOutlet weak var cancelReasonLbl: UILabel!
    @IBOutlet weak var statusWidthConstraints: NSLayoutConstraint!
    @IBOutlet weak var orderTimeLbl: UILabel!
    @IBOutlet weak var orderStatusLbl: UILabel!
    @IBOutlet weak var orderIdLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if Language.isRTL {
            orderTimeLbl.textAlignment = .left
        }
        
        titleLbl.text = "y_order_status".getLocalizedValue()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

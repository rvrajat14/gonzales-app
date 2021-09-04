//
//  ApplyCouponTableCell.swift
//  FoodApplication
//
//  Created by Kishore on 24/07/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class ApplyCouponTableCell: UITableViewCell {

    @IBOutlet weak var couponCrossButton: UIButton!
    @IBOutlet weak var pointsCrossButton: UIButton!
    @IBOutlet weak var couponCodeTxtField: UITextField!
    @IBOutlet weak var couponMainBackV: UIView!
    //@IBOutlet weak var offersListButton: UIButton!
    @IBOutlet weak var couponMainButton: UIButton!
    @IBOutlet weak var couponBottomLbl: UILabel!
    
    @IBOutlet weak var pointsBottomLbl: UILabel!
    @IBOutlet weak var pointsMainButton: UIButton!
    @IBOutlet weak var pointsButton: UIButton!
    @IBOutlet weak var pointsLbl: UILabel!
    @IBOutlet weak var pointBackV: UIView!
    @IBOutlet weak var couponButton: UIButton!
    
    @IBOutlet weak var couponView: UIView!
    @IBOutlet weak var pointsButtonLeadingConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        couponMainButton.setTitle("y_payment_promo_code".getLocalizedValue(), for: .normal)
        pointsMainButton.setTitle("z_points".getLocalizedValue(), for: .normal)
        
        couponButton.setTitle("y_payment_couponlist".getLocalizedValue(), for: .normal)
        pointsButton.setTitle("z_use".getLocalizedValue(), for: .normal)
        couponCodeTxtField.placeholder = "h_coupon".getLocalizedValue()
        
        
        if Language.isRTL {
            couponCodeTxtField.textAlignment = .right
        }
        
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

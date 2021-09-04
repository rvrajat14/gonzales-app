//
//  OnBoardingCollectionCell.swift
//  GotesoMM2
//
//  Created by Kishore on 01/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class OnBoardingCollectionCell: UICollectionViewCell {

    @IBOutlet weak var label2HeightConstraints: NSLayoutConstraint!
    @IBOutlet weak var label1HeightContrainst: NSLayoutConstraint!
    @IBOutlet weak var imgBackViewHeightContraints: NSLayoutConstraint!
    @IBOutlet weak var button: UIButton!
    @IBOutlet weak var buttonBackV: UIView!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var lable1: UILabel!
    @IBOutlet weak var imgV: UIImageView!
    @IBOutlet weak var imgBackView: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        button.setTitle("z_allow".getLocalizedValue(), for: .normal)
    }

}

//
//  SuperMarketCategoryTVCell.swift
//  My MM
//
//  Created by Kishore on 17/11/18.
//  Copyright © 2018 Kishore. All rights reserved.
//

import UIKit

class SuperMarketCategoryTVCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var viewAllButton: UIButton!
    @IBOutlet weak var categoryNameLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
       viewAllButton.setTitle("z_view_all".getLocalizedValue(), for: .normal)
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

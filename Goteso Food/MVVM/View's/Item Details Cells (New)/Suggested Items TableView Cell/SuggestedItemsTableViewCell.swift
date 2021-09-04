//
//  SuggestedItemsTableViewCell.swift
//  GotesoMM2
//
//  Created by Kishore on 30/03/19.
//  Copyright © 2019 Kishore. All rights reserved.
//

import UIKit

class SuggestedItemsTableViewCell: UITableViewCell {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var titleLbl: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
